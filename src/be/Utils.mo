import Time "mo:base/Time";
import Nat64 "mo:base/Nat64";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Float "mo:base/Float";
import Order "mo:base/Order";
import Map "mo:stable-hash-map/Map/Map";
import Vector "mo:vector";
import T "Types";

module {
  type TimeInterval = {
    #minute;
    #hour;
    #day;
    #week;
    #month;
    #year;
  };

  public func aggregateBy(transactions : [T.SwapTransaction], interval : TimeInterval) : [T.SwapTransaction] {
    let filledTransactions = fillMissingValues(transactions, interval);
    let grouped = groupByInterval(filledTransactions, interval);
    return Array.map(
      grouped,
      func(group : [T.SwapTransaction]) : T.SwapTransaction {
        let avgPrice = calculateAveragePrice(group);
        let representativeTx = group[group.size() - 1];
        {
          id = representativeTx.id;
          price = avgPrice;
          ts = representativeTx.ts;
        };
      },
    );
  };

  private func fillMissingValues(transactions : [T.SwapTransaction], interval : TimeInterval) : [T.SwapTransaction] {
    if (transactions.size() == 0) return [];

    let millisInNano = 1_000_000;
    let sortedTransactions = Array.sort(
      transactions,
      func(a : T.SwapTransaction, b : T.SwapTransaction) : Order.Order {
        if (a.ts < b.ts) { return #less };
        if (a.ts > b.ts) { return #greater };
        #equal;
      },
    );
    var filled = Vector.fromArray<T.SwapTransaction>([sortedTransactions[0]]);
    var lastPrice = sortedTransactions[0].price;
    var lastTimestamp = sortedTransactions[0].ts;

    let intervalMillis = switch interval {
      case (#minute) { 60_000 };
      case (#hour) { 3_600_000 };
      case (#day) { 86_400_000 };
      case (#week) { 604_800_000 };
      case (#month) { 2_592_000_000 };
      case (#year) { 31_536_000_000 };
    };

    for (tx in sortedTransactions.vals()) {
      let currentTimestamp = tx.ts;
      while (lastTimestamp + intervalMillis * millisInNano < currentTimestamp) {
        lastTimestamp += intervalMillis * millisInNano;
        let filledTx : T.SwapTransaction = {
          id = 1;
          price = lastPrice;
          ts = lastTimestamp;
        };
        Vector.add(filled, filledTx);
      };
      Vector.add(filled, tx);
      lastPrice := tx.price;
      lastTimestamp := tx.ts;
    };

    return Vector.toArray(filled);
  };

  private func groupByInterval(transactions : [T.SwapTransaction], interval : TimeInterval) : [[T.SwapTransaction]] {
    let millisInNano = 1_000_000;
    let groupedMap = Map.new<Int, Vector.Vector<T.SwapTransaction>>(Map.ihash);

    for (tx in transactions.vals()) {
      let timestampMillis = tx.ts / millisInNano;
      let key = switch interval {
        case (#minute) { timestampMillis / (60_000) };
        case (#hour) { timestampMillis / (3_600_000) };
        case (#day) { timestampMillis / (86_400_000) };
        case (#week) { timestampMillis / (604_800_000) };
        case (#month) { timestampMillis / (2_592_000_000) };
        case (#year) { timestampMillis / (31_536_000_000) };
      };

      let existingGroup = Map.get(groupedMap, Map.ihash, key);
      switch (existingGroup) {
        case (?group) {
          Vector.add(group, tx);
        };
        case (_) {
          let newGroup = Vector.new<T.SwapTransaction>();
          Vector.add(newGroup, tx);
          Map.set(groupedMap, Map.ihash, key, newGroup);
        };
      };
    };

    return Array.map<Vector.Vector<T.SwapTransaction>, [T.SwapTransaction]>(
      Iter.toArray(Map.vals(groupedMap)),
      func(v : Vector.Vector<T.SwapTransaction>) : [T.SwapTransaction] {
        Vector.toArray(v);
      },
    );
  };

  private func calculateAveragePrice(transactions : [T.SwapTransaction]) : Float {
    let total = Array.foldLeft(transactions, 0.0, func(acc : Float, tx : T.SwapTransaction) : Float { acc + tx.price });
    return total / Float.fromInt(transactions.size());
  };
};
