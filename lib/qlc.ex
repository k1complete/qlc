defmodule Qlc do
  @type binding_struct :: :erl_eval.binding_struct()
  @type bindings :: Keyword.t
  @type query_cursor :: Qlc.Cursor.t
  @type abstract_expr :: :erl_parse.abstract_expr()
  @type error_info :: :erl_parse.error_info()
  #@dialyzer [{:nowarn_function, :expr_to_handle, 3}]
  @type expr :: :erl_parse.abstract_expr()
  @type qlc_opt :: tuple()
  @type qlc_opt_list :: [{atom(), any()}|atom()]
  @type table_options :: Keyword.t | tuple()
  @type query_handle() :: :qlc.query_handle() 
  @type qlc_lc :: any 
  @type traverse_fun :: traverse_fun0 | traverse_fun1
  @type traverse_fun1 :: (:ets.match_spec() -> traverse_result()) 
  @type traverse_fun0 :: ( () -> traverse_result() )
  @type traverse_result :: term() | objects()
  @type objects :: [] | [term() | object_list() ]
  @type object_list :: traverse_fun0() | objects()
  @typedoc """
  order function

  detect order if smaller =< bigger then return true else false.
  """
  @type order_fun :: ((smaller :: term(), bigger :: term()) -> boolean())
  @typedoc """
  order option

  order by elixir native ascending, descending or order_fun().
  default is ascending.
  """
  @type order_option :: :ascending | :descending | order_fun()
  @typedoc """
  unique option for sorting.

  only the first of a sequence of terms that compare equal(==) is output
  if this option is set to true. defaults to false.
  """
  @type unique_option:: {:unique, boolean()}

  @typedoc """
  sorting option.

  see `:qlc.sort/2`
  """
  @type sort_option :: {:order, order_option()} |
                       unique_option() | any()
  @type sort_options :: [sort_option()] |
                        sort_option() 

  @typedoc """
  key position for sorting tuples.

  indexed by 0 (elixir's tuple element indexing).
  """
  @type key_pos :: non_neg_integer() | [ non_neg_integer() ]

  require Record
  @doc """
  Returns a query handle. 

  When evaluating returned query handle, 
  the answers to query handle argument are sorted by the query_handle() 
  options.

  ## example

      iex> list = [a: 3, b: 2, c: 1]
      iex> Qlc.q("[ X || X <- L]", [L: list]) |>
      ...> Qlc.sort(order: :descending) |>
      ...> Qlc.e()
      [c: 1, b: 2, a: 3]



  """
  @spec sort(query_handle(), sort_options()) :: query_handle()
  defdelegate sort(qh, opt), to: :qlc
  @doc """
  sorts tuples on query_handle. 

  The sort is performed on the element(s)
  mentioned in key_pos. If two tuples compare equal (==) on one element,
  the next element according to key_pos is compared. The sort is stable.
  key_pos is indexing by 0.

  ## example

      iex> list = [a: 3, b: 2, c: 1]
      iex> Qlc.q("[ X || X <- L]", [L: list]) |>
      ...> Qlc.keysort(1, order: :ascending) |>
      ...> Qlc.e()
      [c: 1, b: 2, a: 3]
      
      iex> list = [a: 1, b: 2, c: 3, d: 2]
      ...> Qlc.q("[X || X <- L]", [L: list]) |>
      ...> Qlc.keysort(1, order: :descending, unique: true) |>
      ...> Qlc.e()
      [c: 3, b: 2, a: 1]


  """
  @spec keysort(query_handle(), key_pos(), sort_options()) :: query_handle()
  def keysort(qh, keypos, opt \\ [])  when keypos >= 0,  do: :qlc.keysort(keypos + 1, qh, opt)
  @doc """
  create qlc handle for any. see `:qlc.table/2`

  ## example
  
      iex> q = Qlc.table(fn() -> [a: 1, b: 2, c: 3] end, [])
      ...> Qlc.q("[X || X = {K, V} <- L, K =:= Y]", [L: q, Y: :a]) |>
      ...> Qlc.e()
      [a: 1]
      
      iex> tf = fn(r, f) -> 
      ...>    [r.first |
      ...>     fn() ->
      ...>       last = r.last 
      ...>       case r.first do
      ...>         x when x < last -> 
      ...>           f.(Range.new(r.first+1, last), f)
      ...>         _x -> []
      ...>       end
      ...>     end] 
      ...>    end
      ...> trf = fn(r) -> tf.(r, tf) end
      ...> q = Qlc.table(fn() -> trf.(1..3) end, [])
      ...> Qlc.q("[X || X <- Q, X > 2]", [Q: q]) |> Qlc.e()
      [3]
  """
  @spec table(traverse_fun(), table_options()) :: query_handle()
  def table(traverse_fun, option \\ []), do: :qlc.table(traverse_fun, option)

  @qlc_handle_fields Record.extract(:qlc_handle, from_lib: "stdlib/src/qlc.erl")
  @qlc_opt_fields Record.extract(:qlc_opt, from_lib: "stdlib/src/qlc.erl")
  @qlc_lc_fields Record.extract(:qlc_lc, from_lib: "stdlib/src/qlc.erl")
  #@qlc_bool_opt_keys [:cache, :unique]
  Record.defrecord :qlc_handle, @qlc_handle_fields
  Record.defrecord :qlc_opt, @qlc_opt_fields
  Record.defrecord :qlc_lc, @qlc_lc_fields

  #@optkeys [:max_lookup,:cache, :join,:lookup,:unique]

  @doc """
  string to erlang ast
  """
  @spec exprs(String.t) :: expr() | no_return()
  def exprs(str) do
    {:ok, m, _} =
      str
      |> String.to_charlist
      |> :erl_scan.string
    {:ok, [expr]} = :erl_parse.parse_exprs(m)
    expr
  end
  @doc """
  optoin list to record(:qlc_opt)
  """
  @spec options(list, atom, Keyword.t) :: qlc_opt
  def options(opt, tagname, field_defs) do
    bool_opts = Enum.filter(field_defs, 
      fn({_k, v}) -> 
        v == false 
      end)
    |> Keyword.keys()
    v = Enum.map(opt, fn(e) ->
      if (Enum.member?(bool_opts, e)) do
        {e, true}
      else
        e
      end
    end)
    |> Keyword.merge(field_defs, fn(_k, v1, _v2) -> v1 end)
    |> Keyword.values()
    List.to_tuple([tagname | v])
  end

  @doc """
  erlang ast with binding variables to qlc_handle
  """
  @spec expr_to_handle(expr(), binding_struct, qlc_opt_list) :: query_handle() | {:qlc_handle, tuple()}
  def expr_to_handle(expr, bind, opt) do
    {:ok, {:call, _, _q, handle}} = :qlc_pt.transform_expression(expr, bind)
    {:value, q, _} = :erl_eval.exprs(handle, bind)
    opt_r = options(opt, :qlc_opt, @qlc_opt_fields)
    lc = qlc_lc(q, opt: opt_r)
    ret = qlc_handle(h: lc)
    ret
  end

  @doc """
  variable binding list to erlang_binding list
  """
  @spec bind(Keyword.t, binding_struct) :: binding_struct
  def bind([], b), do: b
  def bind([{k, v} | t], b) when is_atom(k) do
    bind(t, :erl_eval.add_binding(k, v, b))
  end
  @spec bind(Keyword.t) :: binding_struct
  #def bind(a) when Keyword.keyword?is_list(a),
  def bind(a) when is_list(a),
    do: bind(a, :erl_eval.new_bindings())

  @doc """
  string to qlc_handle with variable bindings
  """
  @spec string_to_handle(String.t, binding_struct, list) :: query_handle() | {:error,:qlc,{non_neg_integer() | {non_neg_integer(),pos_integer()},atom(),any()}}
  def string_to_handle(str, bindings, opt \\ []) when is_binary(str) do
    (String.ends_with?(str, ".") && str || str <> ".") 
    |> String.to_charlist
    |> :qlc.string_to_handle(opt, bindings)
  end

  @doc """
  string to qlc_handle with variable bindings.

  string may be literal or variable.  If string is variable or
  function call, then expanding to string_to_handle/3 automatically.
  elixir expression using bang macro are available to interpolation, 
  but expanding to erlang expression string. see examples.

  ## syntax

      [Expression || Qualifier1, Qualifier2, ...]

      Expression :: arbitary Erlang term (the template)

      Qualifier :: Filter or Generators

      Fiilter :: Erlang expressions returning bool()

      Generator :: Pattern <- ListExpression

      ListExpression :: Qlc_handle or list()

      Qlc_handle :: returned from Qlc.table/2, Qlc.sort/2, Qlc.keysort/3
                                Qlc.q/2, Qlc.string_to_handle/2
  ## example

      iex> require Qlc
      iex> list = [a: 1,b: 2,c: 3]
      iex> qlc_handle = Qlc.q("[X || X = {K,V} <- L, K =/= Item]",
      ...>        [L: list, Item: :b])
      ...> Qlc.e(qlc_handle)
      [a: 1, c: 3]
      ...> Qlc.q("[X || X = {K, V} <- L, K =:= Item]",
      ...>       [L: qlc_handle, Item: :c]) |>
      ...> Qlc.e
      [c: 3]
      ...> query_string = "[X || X = {K, V} <- L, K =:= Item]"
      ...> bindings = [L: list, Item: :b]
      ...> Qlc.q(query_string, bindings) |> Qlc.e()
      [b: 2]
      iex> ## Qlc.Record.defrecord(:user, [id: nil, name: nil, age: nil])
      iex> list = [user(id: 1, name: :foo, age: 10),
      ...>         user(id: 2, name: :bar, age: 20),
      ...>         user(id: 3, name: :baz, age: 30)]
      ...> query_string = "[X || X <- L, \#{user!(X, :age)} < Age]"
      ...> bindings = [L: list, Age: 20]
      ...> Qlc.q(query_string, bindings) |> Qlc.e()
      [{:user, 1, :foo, 10}]

  """
  #@spec q(String.t, bindings, list) :: query_handle
  defmacro q(string, bindings, opt \\ []) do
    case is_binary(string) do
      true ->
        exprl = (String.ends_with?(string, ".") && string || string <> ".")
          |> exprs()
          |> Macro.escape()
        quote bind_quoted: [exprl: exprl, bindings: bindings, opt: opt] do
          Qlc.expr_to_handle(exprl, Qlc.bind(bindings), opt)
        end
      false ->
        quote bind_quoted: [string: string, bindings: bindings, opt: opt] do
          Qlc.string_to_handle(string, Qlc.bind(bindings), opt)
        end
    end
  end
  @doc """
  eval qlc_handle
  """
  @spec e(query_handle) :: list
  defdelegate e(qh), to: :qlc

  @doc """
  fold qlc_handle with accumulator

  ## example

       iex> require Qlc
       iex> list = [a: 1,b: 2,c: 3]
       iex> qlc_handle = Qlc.q("[X || X = {K,V} <- L, K =/= Item]",
       ...>        [L: list, Item: :b])
       ...> Qlc.fold(qlc_handle, [], fn({k,v}, acc) ->
       ...>   [{v, k}|acc]
       ...> end)
       [{3, :c}, {1, :a}]

  """
  @spec fold(query_handle, any, (any, any -> any), [any]) :: any
  def fold(qh, a, f, option \\ []) do
    :qlc.fold(f, a, qh, option)
  end

  @doc """
  create qlc cursor from qlc_handle

  (create processes)
  """
  @spec cursor(query_handle) :: query_cursor
  def cursor(qh), do: %Qlc.Cursor{ c: :qlc.cursor(qh) }

  @doc """
  delete qlc cursor

  (kill processes)
  """
  @spec delete_cursor(Qlc.Cursor.t) :: :ok
  def delete_cursor(qc), do: :qlc.delete_cursor(qc.c)

end
