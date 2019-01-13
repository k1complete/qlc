defmodule QlcTest do
  use ExUnit.Case
  require Record
  doctest Qlc
  
  @user  [id: nil, name: nil, age: nil]
  @company  [id: nil, name: nil]
  @user_company  [user_id: nil, company_id: nil]
  @user_fields Keyword.keys(@user)
  @company_fields Keyword.keys(@company)
  @user_company_fields Keyword.keys(@user_company)

  Record.defrecord :user, @user
  Record.defrecord :user_company, @user_company
  Record.defrecord :company, @company
  
  setup do
    :mnesia.start()
    {:atomic, :ok} = :mnesia.create_table(:user, 
                                          [attributes: @user_fields])
    {:atomic, :ok} = :mnesia.create_table(:company, 
                                          [attributes: @company_fields])
    {:atomic, :ok} = :mnesia.create_table(:user_company, 
                                          [attributes: @user_company_fields])
    on_exit fn ->
              :mnesia.stop()
    end
  end
  test "the truth" do
    assert 1 + 1 == 2
  end
  test "mnesia" do
    u = user(id: 1, name: "foo", age: 10)
    u2 = user(id: 2, name: "bar", age: 20)
    c = company(id: 1, name: "apple")
    uc = user_company(user_id: 1, company_id: 1)
    r = :mnesia.transaction(fn() ->
                              :ok = :mnesia.write(u)
                              :ok = :mnesia.write(u2)
                              :ok = :mnesia.write(c)
                              :ok = :mnesia.write(uc)
                            end)
    assert(r == {:atomic, :ok})
    q = Qlc.q("""
        [{UName, CName} || X={_,UId,UName,UAge} <- U, 
                      Y={_,CId,CName} <- C, 
                      Z={_,UCUId,UCCId} <- UC, 
                      UCUId =:= UId,
                      UCCId =:= CId
        ]
        """, 
              [U: :mnesia.table(:user),
               C: :mnesia.table(:company),
               UC: :mnesia.table(:user_company),
               I: 1], [cache: true, max_lookup: 1, unique: true]) 
    :mnesia.transaction(fn() ->
                          :ok = :mnesia.write(u)
                        end)
    assert(:mnesia.transaction(fn() -> Qlc.e(q) end) == 
             {:atomic, [{user(u,:name),company(c,:name)}]})
    
  end
end
