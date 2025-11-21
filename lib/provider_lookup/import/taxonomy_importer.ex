NimbleCSV.define(TaxonomyParser, separator: ",", escape: "\"")

defmodule ProviderLookup.Import.TaxonomyImporter do
  alias ProviderLookup.Repo
  alias ProviderLookup.Providers.Taxonomy

  @file_path "priv/data/taxonomies.csv"

  def import do
    IO.puts("Starting taxonomy import...")

    rows =
      @file_path
      |> File.stream!()
      |> Stream.drop(1)
      |> TaxonomyParser.parse_stream()
      |> Enum.map(&row_to_map/1)

    Repo.insert_all("taxonomies", rows, timestamps: true)




    IO.puts("Inserted taxonomies!")
  end

  defp row_to_map(row) do
    %{
      taxonomy_code: Enum.at(row, 0),
      taxonomy_classification: Enum.at(row, 1),
      taxonomy_specialization: Enum.at(row, 2)
    }
  end
end
