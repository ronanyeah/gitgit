defmodule Gitgit.Worker do

  def loop do
    receive do
      {sender_pid, offset} ->
        send(sender_pid, {:ok, Gitgit.Helpers.get_users offset})
      _ ->
        IO.puts "don't know how to process this message"
    end
    loop()
  end

end
