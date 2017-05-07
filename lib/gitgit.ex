defmodule Gitgit do
  @moduledoc """
  Scraping github profiles from gitter.
  """

  @room_id Application.get_env(:gitgit, :gitter_room)
  @token Application.get_env(:gitgit, :gitter_token)
  @headers ["Authorization": "Bearer #{@token}"]

  def split100(x) do
    range = 0..(div x, 100)
    Enum.map(range, fn x -> x * 100 end)
  end

  def get_room do
    "https://api.gitter.im/v1/rooms/#{@room_id}" |> get_json
  end

  def get_users(offset) do
    "https://api.gitter.im/v1/rooms/#{@room_id}/users?limit=100&skip=#{offset}" |> get_json
  end

  defp get_json(url) do
    case HTTPoison.get!(url, @headers) do
      %{body: body, status_code: 200} ->
        body |> JSON.decode!
      _ ->
        raise "request error"
    end
  end

end
