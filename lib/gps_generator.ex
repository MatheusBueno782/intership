defmodule Gps do
  alias Expyplot.Plot

  @paris_coords %Geo.Polygon{coordinates: [[{48.817357, 2.333320},{48.835344, 2.254029},{48.878956, 2.279699},{48.901295, 2.321348},{48.901932, 2.385611},{48.884750, 2.399659},{48.878639, 2.410980},{48.833911, 2.411547},{48.816343, 2.356607},{48.817357, 2.333320}]]}
  # paris coords [{48.817357, 2.333320},{48.835344, 2.254029},{48.878956, 2.279699},{48.901295, 2.321348},{48.901932, 2.385611},{48.884750, 2.399659},{48.878639, 2.410980},{48.833911, 2.411547},{48.816343, 2.356607}] 
  @factor 0.000
  defp factor, do: @factor

  def create_coords(polly \\ @paris_coords) do



    {n_coords,e_coords} = polly.coordinates |> List.flatten |> Enum.unzip
    Plot.figure()

    Plot.plot([n_coords,e_coords, :r], [lw: 3])

    
    {{minN,maxN},{minE,maxE}} = {n_coords |> Enum.min_max, e_coords |> Enum.min_max}
    {meanN,meanE} = {(minN + maxN)/2,(minE + maxE)/2}
    
    {deviationN,deviationE} = {maxN - meanN - factor,maxE - meanE - factor} |> IO.inspect



    dots = 0..100 |> Enum.to_list |> Enum.reduce([], fn _i,acc ->
      acc = [%Geo.Point{coordinates: {:rand.normal(meanN,deviationN/70),:rand.normal(meanE,deviationN/40)}}| acc]  

    end)
    
    IO.inspect(dots)
    dots |> Enum.to_list |> Enum.reduce([], fn point,acc ->
      acc = [Topo.contains?(polly, point)| acc]  
    end) |> Enum.filter(fn stat -> stat end) |> Enum.count |> IO.inspect
    
    dots |> List.last |> IO.inspect
    {x,y} = dots |> Enum.map(fn dot -> dot.coordinates end) |> Enum.unzip |> IO.inspect
    Plot.scatter(x, y, [s: 12], [zorder: 2])
    
  Plot.show()
  end
end



