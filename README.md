Qlc
===

Qlc is ported `qlc query interface` from erlang to elixir.

The qlc module implements a query interface to QLC tables. 
Typical QLC tables are ETS, Dets, and Mnesia tables. 
There is also support for user defined tables, see the Implementing 
a QLC table section. A query is stated using Query List 
Comprehensions (QLCs). 

for more information, see 
[erlang reference manual](http://www.erlang.org/doc/man/qlc.html)

## build

1. you found qlc.erl in 'stdlib/src' sure.
2. mix test
3. 

## example

    iex> require Qlc
    iex> list = [a: 1,b: 2,c: 3]
    iex> qlc_handle = Qlc.q("[X || X = {K,V} <- L, K =/= Item]", 
    ...>        [L: list, Item: :b])
    ...> Qlc.e(qlc_handle)
    [a: 1, c: 3]
