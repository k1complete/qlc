defmodule Qlc.Cursor do
  @type t :: %Qlc.Cursor{}
  defstruct c: nil
end

defimpl Enumerable, for: Qlc.Cursor do

  def count(_qc) do
    {:error, __MODULE__}
  end

  def member?(_qc,_) do
    {:error, __MODULE__}
  end

  def reduce(qc, {:halt, acc}, _fun) do
    Qlc.delete_cursor(qc)
    {:halted, acc}
  end

  def reduce(qc, {:suspend, acc}, fun) do
    {:suspended, acc, fn(x) -> reduce(qc, x, fun) end}
  end

  def reduce(qc, {:cont, acc}, fun) do
    case :qlc.next_answers(qc.c, 1) do
      [] ->
        Qlc.delete_cursor(qc)
        {:done, acc}
      [h] ->
        reduce(qc, fun.(h, acc), fun)
    end
  end
  
end
