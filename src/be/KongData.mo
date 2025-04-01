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
  };
  public type AddPoolReply = {
    ts : Nat64;
    request_id : Nat64;
    status : Text;
    tx_id : Nat64;
    lp_token_symbol : Text;
    add_lp_token_amount : Nat;
    transfer_ids : [TransferIdReply];
    name : Text;
    amount_0 : Nat;
    amount_1 : Nat;
    claim_ids : [Nat64];
    address_0 : Text;
    address_1 : Text;
    symbol_0 : Text;
    symbol_1 : Text;
    pool_id : Nat32;
    chain_0 : Text;
    chain_1 : Text;
    is_removed : Bool;
    symbol : Text;
    lp_fee_bps : Nat8;
  };
  public type ICTokenReply = {
    fee : Nat;
    decimals : Nat8;
    token_id : Nat32;
    chain : Text;
    name : Text;
    canister_id : Text;
    icrc1 : Bool;
    icrc2 : Bool;
    icrc3 : Bool;
    is_removed : Bool;
    symbol : Text;
  };
  public type ICTransferReply = {
    is_send : Bool;
    block_index : Nat;
    chain : Text;
    canister_id : Text;
    amount : Nat;
    symbol : Text;
  };
  public type Icrc10SupportedStandards = { url : Text; name : Text };
  public type Icrc28TrustedOriginsResponse = { trusted_origins : [Text] };
  public type LPTokenReply = {
    fee : Nat;
    decimals : Nat8;
    token_id : Nat32;
    chain : Text;
    name : Text;
    address : Text;
    pool_id_of : Nat32;
    is_removed : Bool;
    total_supply : Nat;
    symbol : Text;
  };
  public type PoolReply = {
    tvl : Nat;
    lp_token_symbol : Text;
    name : Text;
    lp_fee_0 : Nat;
    lp_fee_1 : Nat;
    balance_0 : Nat;
    balance_1 : Nat;
    rolling_24h_volume : Nat;
    rolling_24h_apy : Float;
    address_0 : Text;
    address_1 : Text;
    rolling_24h_num_swaps : Nat;
    symbol_0 : Text;
    symbol_1 : Text;
    pool_id : Nat32;
    price : Float;
    chain_0 : Text;
    chain_1 : Text;
    is_removed : Bool;
    symbol : Text;
    rolling_24h_lp_fee : Nat;
    lp_fee_bps : Nat8;
  };
  public type PoolsReply = {
    total_24h_lp_fee : Nat;
    total_tvl : Nat;
    total_24h_volume : Nat;
    pools : [PoolReply];
    total_24h_num_swaps : Nat;
  };
  public type PoolsResult = { #Ok : PoolsReply; #Err : Text };
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
  public type TokenReply = { #IC : ICTokenReply; #LP : LPTokenReply };
  public type TokensResult = { #Ok : [TokenReply]; #Err : Text };
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
    icrc10_supported_standards : shared query () -> async [
      Icrc10SupportedStandards
    ];
    icrc1_name : shared query () -> async Text;
    icrc28_trusted_origins : shared () -> async Icrc28TrustedOriginsResponse;
    pools : shared query ?Text -> async PoolsResult;
    tokens : shared query ?Text -> async TokensResult;
    txs : shared query (?Text, ?Nat64, ?Nat32, ?Nat16) -> async TxsResult;
  };
};
