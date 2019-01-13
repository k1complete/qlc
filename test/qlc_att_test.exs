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
  test "enumerable" do
    list = [{"a",1},{"b",2}]
    e = :ets.new(:testlist, []) 
    qh = :ets.table(e) 
    true = :ets.insert(e, list)
    s = Qlc.cursor(qh)
    d = Enum.to_list(s)
    s = Qlc.cursor(qh)
    assert(2 == Enum.count(s))
    s = Qlc.cursor(qh)
    assert(1 == Enum.filter(s, fn({_k, v}) -> v == 2 end) |> Enum.count())
    s = Qlc.cursor(qh)
    assert(3 == Enum.reduce(s, 0, fn({_k, v}, acc) -> acc + v end))
    query = "[X || X = {K,V} <- L, K =/= Item]"
    s = Qlc.q(query, [L: d, Item: "b"])
    assert([{"a", 1}] ==  Qlc.e(s))
  end
  test "opt" do
    m = Qlc.qlc_opt()
    assert(elem(m, 0) == :qlc_opt)
    m = Qlc.qlc_handle()
    assert(elem(m, 0) == :qlc_handle)
    m = Qlc.qlc_lc()
    assert(elem(m, 0) == :qlc_lc)
    list = [1,2,3]
    q = Qlc.string_to_handle("[X" <> " || X <- L]", [L: list])
    assert(Qlc.e(q) == list)
  end
end
