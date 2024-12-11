import Debug "mo:base/Debug";
import Vector "mo:vector";
import Map "mo:stable-hash-map/Map/Map";
import Time "mo:base/Time";
import Nat16 "mo:base/Nat16";
import Error "mo:base/Error";
import Nat64 "mo:base/Nat64";
import Iter "mo:base/Iter";
import Timer "mo:base/Timer";
import Array "mo:base/Array";
import TrieMap "mo:base/TrieMap";
import Text "mo:base/Text";
import Deque "mo:base/Deque";
import Option "mo:base/Option";
import Data "KongData";
import Swap "KongSwap";
import T "Types";
import Utils "Utils";

actor {

  stable var historicalPrices : Map.Map<Text, Vector.Vector<T.SwapTransaction>> = Map.new<Text, Vector.Vector<T.SwapTransaction>>(Map.thash);
  stable var currentPrices : Map.Map<Text, Float> = Map.new<Text, Float>(Map.thash); // New map for current prices
  stable var mostRecentTxId : Nat64 = 0; // Track the most recent transaction ID
  stable var earliestTxId : Nat64 = Nat64.maximumValue; // Track the earliest transaction ID
  stable var loopTimer : ?Timer.TimerId = null; // Timer for recurring sync

  type Status = {
    mostRecentTxId : Text;
    earliestTxId : Text;
    isSyncing : Bool;
  };

  type PriceInfo = {
    token : Text;
    currentPrice : Float;
  };

  public shared query func getStatus() : async Status {
    return {
      mostRecentTxId = debug_show (mostRecentTxId);
      earliestTxId = debug_show (earliestTxId);
      isSyncing = loopTimer != null;
    };
  };

  public shared query func getTokens() : async [Text] {
    return Iter.toArray(Map.keys(historicalPrices));
  };

  public shared query func getHistoricalPrices(
    token : Text,
    startDate : ?Time.Time,
    endDate : ?Time.Time,
    granularity : ?Text,
  ) : async [T.SwapTransaction] {
    switch (Map.get(historicalPrices, Map.thash, token)) {
      case (?txs) {
        var filteredTxs = Array.filter<T.SwapTransaction>(
          Vector.toArray(txs),
          func(tx : T.SwapTransaction) : Bool {
            let inRange = switch (startDate, endDate) {
              case (?start, ?end) { tx.ts >= start and tx.ts <= end };
              case (?start, null) { tx.ts >= start };
              case (null, ?end) { tx.ts <= end };
              case (null, null) { true };
            };
            inRange;
          },
        );

        // If filteredTxs is empty, add placeholders for start and end of the range
        if (Array.size(filteredTxs) < 2) {
          switch (Map.get(currentPrices, Map.thash, token)) {
            case (?mostRecentPrice) {
              let startPlaceholder : [T.SwapTransaction] = switch (startDate) {
                case (?start) {
                  [{
                    id = 1; // Use a unique ID or timestamp if needed
                    price = mostRecentPrice;
                    ts = start;
                  }];
                };
                case (_) { [] };
              };

              let endPlaceholder : [T.SwapTransaction] = switch (endDate) {
                case (?end) {
                  [{
                    id = 2; // Use a unique ID or timestamp if needed
                    price = mostRecentPrice;
                    ts = end;
                  }];
                };
                case (_) { [] };
              };

              filteredTxs := Array.append(startPlaceholder, endPlaceholder);
            };
            case (_) {
              filteredTxs := []; // No recent price available
            };
          };
        };

        // Apply granularity if specified
        filteredTxs := switch (granularity) {
          case (?gran) {
            switch (gran) {
              case "minute" { Utils.aggregateBy(filteredTxs, #minute) };
              case "hour" { Utils.aggregateBy(filteredTxs, #hour) };
              case "day" { Utils.aggregateBy(filteredTxs, #day) };
              case "week" { Utils.aggregateBy(filteredTxs, #week) };
              case "month" { Utils.aggregateBy(filteredTxs, #month) };
              case "year" { Utils.aggregateBy(filteredTxs, #year) };
              case (_) { filteredTxs };
            };
          };
          case (_) { filteredTxs };
        };

        return filteredTxs;
      };
      case (_) {
        return [];
      };
    };
  };

  public shared query func getMostRecentPrices() : async [PriceInfo] {
    return Iter.toArray(
      Iter.map<(Text, Float), PriceInfo>(
        Map.entries(currentPrices),
        func((token, currentPrice)) {
          return {
            token = token;
            currentPrice = currentPrice;
          };
        },
      )
    );
  };

  // Public method to start the synchronization process
  public shared func startSync(fullScan : Bool) : async () {
    Debug.print("Initiating transaction sync...");
    ignore syncTransactions(fullScan);
  };

  private func syncTransactions(fullScan : Bool) : async () {
    Debug.print("Starting transaction sync...");

    // Fetch and process transactions
    await fetchAndProcessTransactions(fullScan);

    Debug.print("Transaction sync completed.");
  };

  private func fetchAndProcessTransactions(fullScan : Bool) : async () {
    let data = actor ("cbefx-hqaaa-aaaar-qakrq-cai") : Data.Self;

    var startingPoint : ?Nat64 = if (fullScan) ?earliestTxId else null;
    let stoppingPoint : Nat64 = if (fullScan) 24 else mostRecentTxId;
    let LIMIT : Nat16 = 20;
    var iterationCount = 0; // Counter to track the number of iterations
    var hasMore = startingPoint != ?stoppingPoint;

    label fetchTransactions while (hasMore) {
      Debug.print("Fetching transactions with startingPoint: " # debug_show (startingPoint));
      Debug.print("Stopping at: " # debug_show (stoppingPoint));

      try {
        switch (await data.txs(?false, startingPoint, null, ?LIMIT)) {
          case (#Ok(res)) {
            var batchMostRecentTxId : ?Nat64 = null;
            var batchEarliestTxId : ?Nat64 = null;

            Debug.print("Processing # of transactions: " # debug_show (res.size()));
            label processTxs for (tx in res.vals()) {
              switch (tx) {
                case (#Swap(swap)) {
                  let txId = swap.tx_id;

                  Debug.print("Processing transaction: " # debug_show (txId));

                  if (txId <= stoppingPoint) {
                    Debug.print("Reached stopping point. Stopping.");
                    hasMore := false;
                    break processTxs;
                  };

                  // Update batchMostRecentTxId
                  batchMostRecentTxId := switch (batchMostRecentTxId) {
                    case (?existing) {
                      if (txId > existing) { ?txId } else {
                        ?existing;
                      };
                    };
                    case (_) { ?txId };
                  };

                  // Update batchEarliestTxId
                  batchEarliestTxId := switch (batchEarliestTxId) {
                    case (?existing) {
                      if (txId < existing) { ?txId } else {
                        ?existing;
                      };
                    };
                    case (_) { ?txId };
                  };

                  let paySymbol = swap.pay_symbol;
                  let receiveSymbol = swap.receive_symbol;
                  let price = swap.price;
                  let timestamp = swap.ts;

                  if (receiveSymbol == "ckUSDT") {
                    let swapTransaction : T.SwapTransaction = {
                      id = txId;
                      price = price;
                      ts = Nat64.toNat(timestamp);
                    };

                    let txs = Map.get(historicalPrices, Map.thash, paySymbol);
                    switch (txs) {
                      case (?existingTxs) {
                        Vector.add(existingTxs, swapTransaction);
                      };
                      case (_) {
                        let newTxs = Vector.new<T.SwapTransaction>();
                        Vector.add(newTxs, swapTransaction);
                        Map.set(historicalPrices, Map.thash, paySymbol, newTxs);
                      };
                    };
                  };

                };
                case (_) {
                  Debug.print("Unexpected transaction type");
                };
              };
            };

            // Update the earliestTxId with the lowest ID from the current batch
            earliestTxId := switch (batchEarliestTxId) {
              case (?batchId) {
                if (batchId < earliestTxId) {
                  batchId;
                } else {
                  earliestTxId;
                };
              };
              case (_) { earliestTxId };
            };

            // Update the mostRecentTxId with the highest ID from the current batch
            mostRecentTxId := switch (batchMostRecentTxId) {
              case (?batchId) {
                if (batchId > mostRecentTxId) {
                  batchId;
                } else {
                  mostRecentTxId;
                };
              };
              case (_) { mostRecentTxId };
            };

            // Update startingPoint to the txId before the last transaction ID processed
            startingPoint := switch (res[res.size() - 1]) {
              case (#Swap(swap)) { ?(swap.tx_id - 1) };
              case (_) { null };
            };

            // Check if more transactions are available
            hasMore := Option.isSome(startingPoint) and hasMore and res.size() == Nat16.toNat(LIMIT);
          };
          case (#Err(err)) {
            Debug.print("Error fetching transactions: " # err);
            hasMore := false;
          };
        };

      } catch (e) {
        Debug.print("Error syncing Swap history: " # debug_show (Error.message(e)));
        hasMore := false;
      };

      // Increment the iteration counter and check if it has reached 3
      iterationCount += 1;
      if (iterationCount >= 5) {
        Debug.print("Reached maximum iteration count of 3. Stopping.");
        break fetchTransactions;
      };
    };
  };

  public shared func deduplicateTransactions() {
    Debug.print("Deduplicating transactions...");

    for ((symbol, txs) in Map.entries(historicalPrices)) {
      let uniqueTxs = Vector.new<T.SwapTransaction>();
      let seenIds = Map.new<Nat, Bool>(Map.nhash);

      for (tx in Vector.toArray(txs).vals()) {
        // Ignore transactions with ID 0
        if (tx.id != 0 and not Option.isSome(Map.get(seenIds, Map.nhash, Nat64.toNat(tx.id)))) {
          Vector.add(uniqueTxs, tx);
          Map.set(seenIds, Map.nhash, Nat64.toNat(tx.id), true);
        };
      };

      Map.set(historicalPrices, Map.thash, symbol, uniqueTxs);
    };

    Debug.print("Deduplication completed.");
  };

  private func getPricesFromPools() : async () {
    let data = actor ("2ipq2-uqaaa-aaaar-qailq-cai") : Swap.Self;

    try {
      switch (await data.pools(null)) {
        case (#Ok(res)) {
          Debug.print("Processing # of pools: " # debug_show (res.pools.size()));

          // Create a map to store the adjacency list of the graph
          let poolGraph = TrieMap.TrieMap<Text, [Swap.PoolReply]>(Text.equal, Text.hash);

          // Populate the graph with pools
          for (pool in res.pools.vals()) {
            let symbol0Pools = switch (poolGraph.get(pool.symbol_0)) {
              case (?existingPools) { Array.append(existingPools, [pool]) };
              case (_) { [pool] };
            };
            poolGraph.put(pool.symbol_0, symbol0Pools);

            let symbol1Pools = switch (poolGraph.get(pool.symbol_1)) {
              case (?existingPools) { Array.append(existingPools, [pool]) };
              case (_) { [pool] };
            };
            poolGraph.put(pool.symbol_1, symbol1Pools);
          };

          // Process each pool to find the price in terms of ckUSDT
          for (pool in res.pools.vals()) {
            let symbol = pool.symbol_0;
            var queue = Deque.pushBack(Deque.empty<(Text, Float)>(), (symbol, 1.0)); // (current symbol, accumulated price)
            var visited = TrieMap.TrieMap<Text, Bool>(Text.equal, Text.hash);

            label dfs while (not Deque.isEmpty(queue)) {
              let front = Deque.popFront(queue);
              switch (front) {
                case (?((currentSymbol, currentPrice), remainingQueue)) {
                  queue := remainingQueue;

                  if (currentSymbol == "ckUSDT") {
                    // Found a path to ckUSDT
                    Map.set(currentPrices, Map.thash, symbol, currentPrice); // Update current price map

                    let now = Time.now();
                    let swapTransaction : T.SwapTransaction = {
                      id = 0; // Use a unique ID or timestamp if needed
                      price = currentPrice;
                      ts = now;
                    };

                    let txs = Map.get(historicalPrices, Map.thash, symbol);
                    switch (txs) {
                      case (?existingTxs) {
                        let lastPrice = if (Vector.size(existingTxs) > 0) {
                          Vector.get(existingTxs, Vector.size(existingTxs) - 1 : Nat).price;
                        } else {
                          -1.0 // Use a sentinel value that cannot be a valid price
                        };

                        if (lastPrice != currentPrice) {
                          Vector.add(existingTxs, swapTransaction);
                        };
                      };
                      case (_) {
                        let newTxs = Vector.new<T.SwapTransaction>();
                        Vector.add(newTxs, swapTransaction);
                        Map.set(historicalPrices, Map.thash, symbol, newTxs);
                      };
                    };

                    break dfs;
                  };

                  if (not Option.isSome(visited.get(currentSymbol))) {
                    visited.put(currentSymbol, true);

                    let neighbors = switch (poolGraph.get(currentSymbol)) {
                      case (?pools) { pools };
                      case (_) { [] };
                    };

                    for (neighbor in neighbors.vals()) {
                      let nextSymbol = if (neighbor.symbol_0 == currentSymbol) neighbor.symbol_1 else neighbor.symbol_0;
                      let nextPrice = currentPrice * neighbor.price;
                      queue := Deque.pushBack(queue, (nextSymbol, nextPrice));
                    };
                  };
                };
                case (_) {
                  // Queue is empty, no path found
                };
              };
            };
          };

        };
        case (#Err(err)) {
          Debug.print("Error fetching pools: " # err);
        };
      };
    } catch (e) {
      Debug.print("Error fetching pools: " # debug_show (Error.message(e)));
    };
  };

  public shared func startTimer() : async () {
    startSystemLoop<system>();
  };

  public shared func stopTimer() : async () {
    stopSystemLoop();
  };

  // Start the recurring system loop
  private func startSystemLoop<system>() {
    let tickRate = #seconds(60);
    switch (loopTimer) {
      case (null) {
        Debug.print("Starting system loop.");
        loopTimer := ?Timer.recurringTimer<system>(tickRate, systemLoop);
      };
      case (?exists) {
        Timer.cancelTimer(exists);
        loopTimer := ?Timer.recurringTimer<system>(tickRate, systemLoop);
      };
    };
  };

  // Stop the recurring system loop
  private func stopSystemLoop() {
    switch (loopTimer) {
      case (?timer) {
        Debug.print("Stopping system loop.");
        Timer.cancelTimer(timer);
        loopTimer := null;
      };
      case (_) {};
    };
  };

  // The system loop function to be called by the timer
  private func systemLoop() : async () {
    Debug.print("Executing system loop...");
    try {

      await syncTransactions(false); // Fetch new transactions
      await syncTransactions(true); // Fetch previous transactions
      await getPricesFromPools(); // Fetch prices from pools
    } catch (e) {
      Debug.print("Error in system loop: " # debug_show (Error.message(e)));
    };
  };

  startSystemLoop<system>();

};
