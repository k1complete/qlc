defmodule QlcTest2 do
  use ExUnit.Case
  require Record
  require Qlc
  test "variables" do
    list = [["a",1],["b",2]]
    test_param = [L: list, Item: "b"]
    query = "[X || X = [K,V] <- L, K =/= Item]"
    s = Qlc.q(query,  test_param)
    assert([["a", 1]] ==  Qlc.e(s))
  end
end
