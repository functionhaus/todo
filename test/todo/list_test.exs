defmodule Todo.ListTest do
  use ExUnit.Case, async: true

  test "create an empty todo list" do
    assert Todo.List.new == %Todo.List{auto_id: 1, entries: %{}}
  end

  test "create a todo list with entries" do
    assert %Todo.List{entries: entries} =
      Todo.List.new([%{an: "entry"}, %{another: "entry"}])

    assert entries == %{
      1 => %{an: "entry", id: 1},
      2 => %{another: "entry", id: 2}
    }
  end

  test "add entries" do
    list = Todo.List.new
      |> Todo.List.add_entry(%{some: "entry"})
      |> Todo.List.add_entry(%{another: "entry"})

    assert list.entries == %{
      1 => %{some: "entry", id: 1},
      2 => %{another: "entry", id: 2}
    }
  end

  test "retrieving entries by date" do
    list = Todo.List.new
      |> Todo.List.add_entry(%{date: {2016, 01, 01}})
      |> Todo.List.add_entry(%{date: {2016, 01, 01}})
      |> Todo.List.add_entry(%{date: {2017, 12, 31}})

    assert Todo.List.entries(list, {2016, 01, 01})
      == [list.entries[1], list.entries[2]]

    assert Todo.List.entries(list, {2017, 12, 31})
      == [list.entries[3]]

    assert Todo.List.entries(list, {1995, 06, 20})
      == []
  end

  test "updating an entry" do
    list = Todo.List.new
      |> Todo.List.add_entry(%{date: {2016, 01, 01}})
      |> Todo.List.add_entry(%{date: {2017, 12, 31}})

    updater_fun = &Map.put(&1, :date, {1900, 01, 01})

    # updating a non-existent id should not change the list
    assert Todo.List.update_entry(list, 20, updater_fun) == list

    # updating a valid id should, though
    new_list = Todo.List.update_entry(list, 1, updater_fun)
    assert new_list.entries[1] == %{id: 1, date: {1900, 01, 01}}
  end

  test "update fails if updater doesn't return a map" do
    list = Todo.List.new
      |> Todo.List.add_entry(%{date: {2016, 01, 01}})

    # returns the entry wrapped in a list
    updater_fun = &([&1])

    assert_raise MatchError, fn ->
      Todo.List.update_entry(list, 1, updater_fun)
    end
  end

  test "update fails if updater changes the list id" do
    list = Todo.List.new
      |> Todo.List.add_entry(%{date: {2016, 01, 01}})

    # updater expressly changes the id
    updater_fun = &Map.put(&1, :id, 20)

    assert_raise MatchError, fn ->
      Todo.List.update_entry(list, 1, updater_fun)
    end

  end

  test "deleting an entry" do
    list = Todo.List.new
      |> Todo.List.add_entry(%{date: {2016, 01, 01}})

    # updating a non-existent id should not change the list
    assert %Todo.List{entries: %{}} =
      Todo.List.delete_entry(list, 1)
  end
end
