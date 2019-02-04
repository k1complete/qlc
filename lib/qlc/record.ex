require Elixir.Record
defmodule Qlc.Record do
  @moduledoc """
  Record enhancement

  bang!/2 macro provide erlang expression for record access
  in QLC expression.

  ## example

      iex> user([id: 1, name: :foo, age: 10]) 
      {:user, 1, :foo, 10}
      iex> List.flatten(user!({:user, 1, :foo, 10}, :name))
      ' element(3, {user,1,foo,10}) '
      iex> "\#{user!({:user, 2, :bar, 10}, :age)}"
      " element(4, {user,2,bar,10}) "


  """

  @doc """
  define __fields__/1 function for getting record definition

  ## example


  """
  defmacro defrecord(tag, args) do
    vtag = :"#{tag}!"
    quote do 
      require Elixir.Record
      m = unquote(tag)
      #IO.inspect(tag: quote do: unquote(m))
      Elixir.Record.defrecord(unquote(tag), unquote(args))
      def __fields__(unquote(tag)) do
        Elixir.Record.__fields__(unquote(tag), unquote(args))
      end
      defmacro unquote(vtag)(x,a) do
        f = Elixir.Record.__fields__(unquote(tag), unquote(args))
        y = case x do
              {:__aliases__, _, [y]} ->
                Atom.to_string(y)
              x ->
                {y, []} = Code.eval_quoted(x)
                :io_lib.format('~p', [y])
            end
        ##:io.format('[~p]~n', [y])
        i = Enum.find_index(f, fn({k, v}) -> k == a end) + 2
        quote do
          :io_lib.format(' element(~p, ~s) ', [unquote(i), unquote(y)])
        end
      end
    end
  end
end
