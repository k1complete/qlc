Qlc
===

[![Build Status](https://travis-ci.org/k1complete/qlc.svg?branch=master)](https://travis-ci.org/k1complete/qlc)

Qlc is implementation `erlang's qlc interface` by elixir.

The qlc module implements a query interface to QLC tables. 
Typical QLC tables are ETS, Dets, and Mnesia tables. 
There is also support for user defined tables, see the Implementing 
a QLC table section. A query is stated using Query List 
Comprehensions (QLCs). 

for more information, see 
[erlang reference manual](http://www.erlang.org/doc/man/qlc.html)

## build

1. find sure qlc.erl in 'stdlib/src'.
2. mix test
3. mix docs (option)

## feature

Allow erlang style list comprehensions for List, ets, Dets, Mnesia QLC tables.

### example

    iex> require Qlc
    iex> list = [a: 1,b: 2,c: 3]
    iex> qlc_handle = Qlc.q("[X || X = {K,V} <- L, K =/= Item]", 
    ...>        [L: list, Item: :b])
    ...> Qlc.e(qlc_handle)
    [a: 1, c: 3]

Qlc.Record.defrecord/2 defines the bang!/2 macro expanding to 
'element(index, record)', for treating record element in qlc query.

### Examples

    iex> require Qlc.Record
    iex> require Qlc
    iex> Qlc.Record.defrecord(:item, [id: nil, name: nil, weight: nil])
    iex> item(2, :a, 1) == {:item, :a, 1}
    true
    item> item!(item(2, :a, 1), :name)
    element(3, {:item, :a, 1})
    
    iex> list = [item(1, :a, 1), item(2, :b, 10), item(3, :c, 20)]
    iex> Qlc.q("[ X || X <- L, (N = #{item!(X)}) =:= Name]", 
    ...>   [L: list, 
    ...>    Name: :b]) |>
    ...> Qlc.sort(order: :descending) |>
    ...> Qlc.e()
    [{:item, 2, :b, 10}]

## licenses

MIT licenses.

