defmodule Gitgit.Coordinator do

  def loop(results \\ [], results_expected) do
    receive do
      {:ok, result} ->
        new_results = [result | results]
        if results_expected == Enum.count(new_results) do
          send self, :exit
        end
        loop(new_results, results_expected)
      :exit ->
        data = List.flatten(results)
        usernames = Enum.map(data, fn x -> Map.get(x, "username") end)
        json = JSON.encode!(usernames)
        IO.puts Enum.count(usernames)
        File.write("./done.json", json)
      _ ->
        loop(results, results_expected)
    end
  end

end

