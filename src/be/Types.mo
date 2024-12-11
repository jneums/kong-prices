import Time "mo:base/Time";

module {
  public type SwapTransaction = {
    id : Nat64;
    price : Float;
    ts : Time.Time;
  };
};
