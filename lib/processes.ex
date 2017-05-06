defmodule Gitgit.Processes do

  def loop do
    receive do
      {sender_pid, offset} ->
        send(sender_pid, {:ok, Gitgit.Helpers.get_users(offset)})
      _ ->
        IO.puts "don't know how to process this message"
    end
    loop()
  end

  def coordinator(results \\ [], results_expected) do
    receive do
      {:ok, result} ->
        new_results = [result | results]
        if results_expected == Enum.count(new_results) do
          send self, :exit
        end
        coordinator(new_results, results_expected)
      :exit ->
        data = List.flatten(results)
        usernames = Enum.map(data, fn x -> Map.get(x, "username") end)
        Gitgit.add_results(usernames)
        Gitgit.stop
      _ ->
        coordinator(results, results_expected)
    end
  end

end
