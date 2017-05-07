room_id = Application.get_env(:gitgit, :gitter_room)

%{ "userCount" => userCount } = Gitgit.get_gitter_room(room_id)

usernames =
  userCount
  |> Gitgit.split100
  |> Enum.map(fn offset ->
       Task.async(fn -> Gitgit.get_gitter_room_members(room_id, offset) end)
     end)
  |> Gitgit.yield_and_parse_tasks
  |> List.flatten
  |> Enum.map(&(Map.get(&1, "username")))

profiles =
  usernames
  |> Enum.map(fn username ->
       Task.async(fn -> Gitgit.get_github_profile(username) end)
     end)
  |> Gitgit.yield_and_parse_tasks
  |> Enum.map(&(Map.take(&1, ["name", "location", "email", "company", "login"])))
  |> JSON.encode!

File.write("data.json", profiles)
