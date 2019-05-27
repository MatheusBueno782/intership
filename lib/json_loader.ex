defmodule JsonLoader do 
  def upload_files(file_list, bucket) do
    workers = 1..10 
              |> Enum.map(fn _ -> 
                {:ok,pid} = Agent.start_link(fn-> [] end); pid end)
    file_list 
    |> Stream.map(fn x -> Poison.decode!(File.read!(x)) end)
    |> Stream.concat
    |> Enum.take(10)
    |> Stream.zip(Stream.cycle(workers))
    |> Stream.chunk(1_00, 1_00, [])
    |> Stream.map( fn chunk -> 
      Enum.map(chunk, fn {order, worker} -> 
        Agent.cast(worker, fn _ -> Riak.create(bucket, order["id"], Poison.encode!(order)) end)
      end) #Enum map
      workers |> Enum.map(fn w -> Agent.get(w, &(&1), :infinity) end)
    end) #Stream map
    |> Stream.run
    workers |> Enum.map(fn w -> Agent.stop(w) end) |> IO.inspect
  end

  def upload_files(file_list) do
    workers = 1..10 
              |> Enum.map(fn _ -> 
                {:ok,pid} = Agent.start_link(fn-> [] end); pid end)
    file_list 
    |> Stream.map(fn x -> Poison.decode!(File.read!(x)) end)
    |> Stream.concat
    |> Enum.take(10)
    |> Stream.zip(Stream.cycle(workers))
    |> Stream.chunk(1_00, 1_00, [])
    |> Stream.map( fn chunk -> 
      Enum.map(chunk, fn {order, worker} -> 
        {_res, updated_order} = Kernel.get_and_update_in(order,["status", "state"], &{&1, "init"})
        Agent.cast(worker, fn _ -> Server.Database.create(updated_order["id"], updated_order) end)
      end) #Enum map
      workers |> Enum.map(fn w -> Agent.get(w, &(&1), :infinity) end)
    end) #Stream map
    |> Stream.run
    workers |> Enum.map(fn w -> Agent.stop(w) end) |> IO.inspect
  end

   def initialize_commands(bucket) do
    Riak.get_keys(bucket)
    |> Enum.map(
      fn key ->
        command = Riak.get(bucket, key) |> Poison.decode!
        command = Kernel.get_and_update_in(command["status"]["state"], fn state -> {state, "init"} end)
                  |> elem(1) |> Poison.encode!
        Riak.create(bucket, key, command)
      end)
  end
end
