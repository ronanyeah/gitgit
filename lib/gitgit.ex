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
    "https://api.gitter.im/v1/rooms/#{@room_id}" |> HTTPoison.get(@headers) |> parse_response
  end

  def get_users(offset) do
    result =  "https://api.gitter.im/v1/rooms/#{@room_id}/users?limit=100&skip=#{offset}" |> HTTPoison.get(@headers) |> parse_response
    case result do
      {:ok, res} ->
        res
      {:error, reason} ->
        IO.puts "ERROR: #{inspect reason}"
        []
    end

  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode
  end

  defp parse_response(_) do
    { :error, "oops" }
  end

end
