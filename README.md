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

    iex(1)> require Qlc.Record
    Qlc.Record
    iex(2)> require Qlc
    Qlc
    iex(3)> defmodule A do
    ...(3)> Qlc.Record.defrecord(:item, [id: nil, name: nil, age: nil])
    ...(3)> end
    {:module, A,
     <<70, 79, 82, 49, 0, 0, 10, 48, 66, 69, ...>>, {:item!, 2}}
    iex(4)> require A
    A
    iex(5)> import A
    A
    iex(6)> item()
    {:item, nil, nil, nil}
    iex(7)> item([id: 1, name: :foo, age: 10])
    {:item, 1, :foo, 10}
    iex(8)> item!({:item, 1, :foo, 10}, :age)
    [
      32,
      101,
      108,
      101,
      109,
      101,
      110,
      116,
      40,
      '4',
      44,
      32,
      [[123, ['item', 44, '1', 44, 'foo', 44, '10'], 125]],
      41,
      32
    ]
    iex(9)> item!({:item, 1, :foo, 10}, :age)|>List.flatten()
    ' element(4, {item,1,foo,10}) '
    iex(10)> list = [item(id: 1, name: :a, age: 1), 
    ...(10)>         item(id: 2, name: :b, age: 10), 
    ...(10)>         item(id: 3, name: :c, age: 20)]
    [{:item, 1, :a, 1}, {:item, 2, :b, 10}, {:item, 3, :c, 20}]
    iex(11)> Qlc.q("[ X || X <- L, (N = #{item!(X, :name)}) =:= Name]", 
    ...(11)>      [L: list, Name: :b]) |>
    ...(11)> Qlc.sort(order: :descending) |>
    ...(11)> Qlc.e()
    [{:item, 2, :b, 10}]

    ## Cannot use bang!/2 macro with variable, can use literal only

    iex(12)> b = item([id: 1, name: :foo, age: 10])
    {:item, 1, :foo, 10}
    iex(13)> item!(b, :name)
    warning: variable "b" does not exist and is being expanded to "b()", please use parentheses to remove the ambiguity or change the variable name
    iex(14)> 

## licenses
    
MIT licenses.
    
