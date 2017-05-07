defmodule Gitgit do
  @moduledoc """
  Scraping github profiles from gitter.
  """

  @gitter_headers ["Authorization": "Bearer #{Application.get_env(:gitgit, :gitter_token)}"]
  @github_headers ["Authorization": "token #{Application.get_env(:gitgit, :github_token)}"]

  def split100(x) do
    range = 0..(div x, 100)
    Enum.map(range, fn x -> x * 100 end)
  end

  def get_gitter_room(room_id) do
    "https://api.gitter.im/v1/rooms/#{room_id}" |> gitter_get
  end

  def get_gitter_room_members(room_id, offset) do
    "https://api.gitter.im/v1/rooms/#{room_id}/users?limit=100&skip=#{offset}" |> gitter_get
  end

  def get_github_profile(username) do
    case HTTPoison.get!("https://api.github.com/users/#{username}", @github_headers) do
      %{body: body, status_code: 200} ->
        body |> JSON.decode!
      %{status_code: 404} ->
        %{}
      _ ->
        raise "github request error"
    end
  end

  def yield_and_parse_tasks(tasks) do
    tasks
    |> Task.yield_many
    |> Enum.map(fn {task, res} ->
         res || Task.shutdown(task, :brutal_kill)
       end)
    |> Enum.map(fn {:ok, res} -> res end)
  end

  defp gitter_get(url) do
    case HTTPoison.get!(url, @gitter_headers) do
      %{body: body, status_code: 200} ->
        body |> JSON.decode!
      _ ->
        raise "gitter request error"
    end
  end

end
