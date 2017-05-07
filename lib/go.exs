room_id = Application.get_env(:gitgit, :gitter_room)

%{ "userCount" => userCount } = Gitgit.get_gitter_room(room_id)

usernames =
  userCount
  |> Gitgit.split100
  |> Task.async_stream(
       &(Gitgit.get_gitter_room_members(room_id, &1))
     )
  |> Enum.map(fn {:ok, res} -> res end)
  |> List.flatten
  |> Enum.map(&(Map.get(&1, "username")))

profiles =
  usernames
  |> Task.async_stream(
       &(Gitgit.get_github_profile(&1))
     )
  |> Enum.map(fn {:ok, res} -> res end)
  |> Enum.map(&(Map.take(&1, ["name", "location", "email", "company", "login"])))

json = JSON.encode!(profiles)

File.write("data.json", json)
