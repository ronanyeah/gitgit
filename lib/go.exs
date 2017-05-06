case Gitgit.get_room do

  {:ok, json} ->
    tasks =
      json["userCount"]
      |> Gitgit.split100
      |> Enum.map(fn offset ->
           Task.async(fn -> Gitgit.get_users(offset) end)
         end)

    data =
      tasks
      |> Task.yield_many
      |> Enum.map(fn {task, res} ->
           res || Task.shutdown(task, :brutal_kill)
         end)
      |> Enum.map(fn {:ok, res} -> res end)
      |> List.flatten
      |> Enum.map(&(Map.get(&1, "username")))
      |> JSON.encode!

    File.write("data.json", data)

  {:error, reason} ->
    "ERROR: #{inspect reason}"

end
