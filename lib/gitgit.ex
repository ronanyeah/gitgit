defmodule Gitgit do
  @moduledoc """
  Scraping github profiles from gitter.
  """

  @gitter_headers ["Authorization": "Bearer #{Application.get_env(:gitgit, :gitter_token)}"]
  @github_headers ["Authorization": "token #{Application.get_env(:gitgit, :github_token)}"]

  @doc """
  Splits integer in increments of 100 for rate limited API requests.

  ## Examples

      iex> Gitgit.split100(432)
      [0, 100, 200, 300, 400]
  """
  def split100(x) do
    0..(div x, 100)
    |> Enum.map(&(&1 * 100))
  end

  def get_gitter_room(room_id) do
    url = "https://api.gitter.im/v1/rooms/#{room_id}"

    case HTTPoison.get!(url, @gitter_headers) do
      %{status_code: 200, body: body} ->
        body |> JSON.decode!
      _ ->
        raise "gitter request error"
    end
  end

  def get_gitter_room_members(room_id, offset) do
    url = "https://api.gitter.im/v1/rooms/#{room_id}/users?limit=100&skip=#{offset}"

    case HTTPoison.get!(url, @gitter_headers) do
      %{status_code: 200, body: body} ->
        body |> JSON.decode!
      _ ->
        raise "gitter request error"
    end
  end

  def get_github_profile(username) do
    case HTTPoison.get!("https://api.github.com/users/#{username}", @github_headers) do
      %{status_code: 200, body: body} ->
        body |> JSON.decode!
      %{status_code: 404} ->
        %{}
      _ ->
        raise "github request error"
    end
  end

end
