defmodule Gps do
  @paris_coords %Geo.Polygon{coordinates: [[{48.817357, 2.333320},{48.835344, 2.254029},{48.878956, 2.279699},{48.901295, 2.321348},{48.901932, 2.385611},{48.884750, 2.399659},{48.878639, 2.410980},{48.833911, 2.411547},{48.816343, 2.356607}]]}
  # paris coords [{48.817357, 2.333320},{48.835344, 2.254029},{48.878956, 2.279699},{48.901295, 2.321348},{48.901932, 2.385611},{48.884750, 2.399659},{48.878639, 2.410980},{48.833911, 2.411547},{48.816343, 2.356607}] 
  def create_coords(polly \\ @paris_coords) do
    {n_coords,e_coords} = polly.coordinates |> List.flatten |> Enum.unzip
    
    {{minN,maxN},{minE,maxE}} = {n_coords |> Enum.min_max, e_coords |> Enum.min_max}
    
    %Geo.Point{coordinates: {Enum.random(minN..maxN),Enum.random(minE..maxE)}}
    
      

  end
end
