// This is a generated Motoko binding.
// Please use `import service "ic:canister_id"` instead to call canisters on the IC if possible.

module {
  public type AddLiquidityArgs = {
    token_0 : Text;
    token_1 : Text;
    amount_0 : Nat;
    amount_1 : Nat;
    tx_id_0 : ?TxId;
    tx_id_1 : ?TxId;
  };
  public type AddLiquidityReply = {
    ts : Nat64;
    request_id : Nat64;
    status : Text;
    tx_id : Nat64;
    add_lp_token_amount : Nat;
    transfer_ids : [TransferIdReply];
    amount_0 : Nat;
    amount_1 : Nat;
    claim_ids : [Nat64];
    address_0 : Text;
    address_1 : Text;
    symbol_0 : Text;
    symbol_1 : Text;
    chain_0 : Text;
    chain_1 : Text;
    symbol : Text;
  };
  public type AddPoolArgs = {
    token_0 : Text;
    token_1 : Text;
    amount_0 : Nat;
    amount_1 : Nat;
    tx_id_0 : ?TxId;
    tx_id_1 : ?TxId;
    lp_fee_bps : ?Nat8;
    on_kong : ?Bool;
  };
  public type AddPoolReply = {
    ts : Nat64;
    request_id : Nat64;
    status : Text;
    tx_id : Nat64;
    lp_token_symbol : Text;
    add_lp_token_amount : Nat;
    transfer_ids : [TransferIdReply];
    amount_0 : Nat;
    amount_1 : Nat;
    claim_ids : [Nat64];
    address_0 : Text;
    address_1 : Text;
    symbol_0 : Text;
    symbol_1 : Text;
    chain_0 : Text;
    chain_1 : Text;
    symbol : Text;
    lp_fee_bps : Nat8;
    on_kong : Bool;
  };
  public type ICTransferReply = {
    is_send : Bool;
    block_index : Nat;
    chain : Text;
    canister_id : Text;
    amount : Nat;
    symbol : Text;
  };
  public type RemoveLiquidityArgs = {
    token_0 : Text;
    token_1 : Text;
    remove_lp_token_amount : Nat;
  };
  public type RemoveLiquidityReply = {
    ts : Nat64;
    request_id : Nat64;
    status : Text;
    tx_id : Nat64;
    transfer_ids : [TransferIdReply];
    lp_fee_0 : Nat;
    lp_fee_1 : Nat;
    amount_0 : Nat;
    amount_1 : Nat;
    claim_ids : [Nat64];
    address_0 : Text;
    address_1 : Text;
    symbol_0 : Text;
    symbol_1 : Text;
    chain_0 : Text;
    chain_1 : Text;
    remove_lp_token_amount : Nat;
    symbol : Text;
  };
  public type RequestReply = {
    #AddLiquidity : AddLiquidityReply;
    #Swap : SwapReply;
    #AddPool : AddPoolReply;
    #RemoveLiquidity : RemoveLiquidityReply;
    #Pending;
  };
  public type RequestRequest = {
    #AddLiquidity : AddLiquidityArgs;
    #Swap : SwapArgs;
    #AddPool : AddPoolArgs;
    #RemoveLiquidity : RemoveLiquidityArgs;
  };
  public type RequestsReply = {
    ts : Nat64;
    request_id : Nat64;
    request : RequestRequest;
    statuses : [Text];
    reply : RequestReply;
  };
  public type RequestsResult = { #Ok : [RequestsReply]; #Err : Text };
  public type SwapArgs = {
    receive_token : Text;
    max_slippage : ?Float;
    pay_amount : Nat;
    referred_by : ?Text;
    receive_amount : ?Nat;
    receive_address : ?Text;
    pay_token : Text;
    pay_tx_id : ?TxId;
  };
  public type SwapReply = {
    ts : Nat64;
    txs : [SwapTxReply];
    request_id : Nat64;
    status : Text;
    tx_id : Nat64;
    transfer_ids : [TransferIdReply];
    receive_chain : Text;
    mid_price : Float;
    pay_amount : Nat;
    receive_amount : Nat;
    claim_ids : [Nat64];
    pay_symbol : Text;
    receive_symbol : Text;
    receive_address : Text;
    pay_address : Text;
    price : Float;
    pay_chain : Text;
    slippage : Float;
  };
  public type SwapTxReply = {
    ts : Nat64;
    receive_chain : Text;
    pay_amount : Nat;
    receive_amount : Nat;
    pay_symbol : Text;
    receive_symbol : Text;
    receive_address : Text;
    pool_symbol : Text;
    pay_address : Text;
    price : Float;
    pay_chain : Text;
    lp_fee : Nat;
    gas_fee : Nat;
  };
  public type TransferIdReply = {
    transfer_id : Nat64;
    transfer : TransferReply;
  };
  public type TransferReply = { #IC : ICTransferReply };
  public type TxId = { #TransactionId : Text; #BlockIndex : Nat };
  public type TxsReply = {
    #AddLiquidity : AddLiquidityReply;
    #Swap : SwapReply;
    #AddPool : AddPoolReply;
    #RemoveLiquidity : RemoveLiquidityReply;
  };
  public type TxsResult = { #Ok : [TxsReply]; #Err : Text };
  public type Self = actor {
    get_requests : shared query (
      ?Nat64,
      ?Nat32,
      ?Nat16,
    ) -> async RequestsResult;
    get_txs : shared query (?Nat64, ?Nat64, ?Nat32, ?Nat16) -> async TxsResult;
    icrc1_name : shared query () -> async Text;
    requests : shared query (?Nat64, ?Nat16) -> async RequestsResult;
    txs : shared query (?Bool, ?Nat64, ?Nat32, ?Nat16) -> async TxsResult;
  };
};
