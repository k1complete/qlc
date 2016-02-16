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

## example

    iex> require Qlc
    iex> list = [a: 1,b: 2,c: 3]
    iex> qlc_handle = Qlc.q("[X || X = {K,V} <- L, K =/= Item]", 
    ...>        [L: list, Item: :b])
    ...> Qlc.e(qlc_handle)
    [a: 1, c: 3]
