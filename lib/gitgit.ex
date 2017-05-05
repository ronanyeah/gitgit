defmodule Gitgit do
  @moduledoc """
  Scraping github profiles from gitter.
  """

  @room_id Application.get_env(:gitgit, :gitter_room)

  def go do
    case Gitgit.Helpers.get_room(@room_id) do
      {:ok, json} ->
        offsets = Gitgit.Helpers.split100 json["userCount"]

        coordinator_pid = spawn(Gitgit.Coordinator, :loop, [[], Enum.count(offsets)])

        offsets |> Enum.each(fn offset ->
          worker_pid = spawn(Gitgit.Worker, :loop, [])
          send worker_pid, {coordinator_pid, offset}
        end)
      {:error, reason} ->
        "ERROR: #{inspect reason}"
    end
  end

end
