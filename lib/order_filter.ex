defmodule Order do


  defmodule Parallel do
    def map(collection, func) do
      collection
      |> Enum.map(&(Task.async(fn -> func.(&1) end)))
      |> Enum.map(&Task.await/1)
    end
  end

  def convertData(path,file_n) do 
    Enum.to_list(0..file_n)
    |> Enum.map(fn number -> "#{path}/orders_chunk#{number}.json" 
      |> File.read! 
      |> Poison.decode! 
    end) |> List.flatten 
    |> Order.Parallel.map(fn data -> Enum.filter(data, 
      fn {key,_value} ->

        case key do
          "remoteid"  -> true
          "custom"    -> true
          _           -> false
        end
      end) 
    end)
      |> Enum.reduce([],fn [custom|id],acc ->
        {_,id} = id |> List.last 
        {_,val} = custom
        aux = %{:id => "", :address => %{}, :items => []}
        aux = Map.replace(aux,:id,id)
        
        aux = Map.replace(aux, :address, 
          val["shipping_address"] |> Enum.reject(fn {key,_} -> 
            case key do
              "company"   -> true
              "email"     -> true
              "firstname" -> true
              "lastname"  -> true
              "prefix"    -> true
              "telephone" -> true
              _           -> false
            end
          end) 
          |> Enum.into(%{}))

        
          aux = Map.replace(aux,:items, val["items"] 
                |> Enum.reduce([],fn item,acc ->  item_filtered = Enum.filter(item,fn {key,_} ->
                    case key do 
                      "price"             ->  true
                      "weight"            ->  true
                      "product_title"     ->  true
                      "quantity_to_fetch" ->  true
                      _                   ->  false
                    end
                end) |> Enum.into(%{})
                [item_filtered|acc]

                end))

        [aux|acc]
      end) |>  Poison.encode! |> write("orders.json",[:binary])
  end

  def write(json,path,opts) do
    File.write(path,json,opts)
  end

end
