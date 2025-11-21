NimbleCSV.define(ProviderParser, separator: ",", escape: "\"")

defmodule ProviderLookup.Import.ProviderImporter do
  alias ProviderLookup.Repo
  alias ProviderLookup.Providers.Provider

  @file_path "priv/data/npidata_pfile_20050523-20251109.csv"
  @batch_size 5000

  def import do
    IO.puts("Starting provider import...")

    @file_path
    |> File.stream!()
    |> Stream.drop(1)
    |> Stream.map(&safe_parse/1)
    |> Stream.reject(&is_nil/1)
    |> Stream.chunk_every(@batch_size)
    |> Enum.each(&insert_batch/1)

    IO.puts("Provider import completed!")
  end

  # SAFE PARSE using MyParser
  defp safe_parse(line) do
    case ProviderParser.parse_string(line) do
      [columns] ->
        parse_columns(columns)

      _ ->
        nil
    end
  end

  defp parse_columns(columns) do
    if length(columns) < 30 do
      nil
    else
      %{
        npi_number: Enum.at(columns, 0),
        first_name: Enum.at(columns, 6),
        last_name: Enum.at(columns, 5),
        organization_name: Enum.at(columns, 4),

        # Mailing address fields
        address_line: Enum.at(columns, 20),
        city: Enum.at(columns, 22),
        state: Enum.at(columns, 23),
        postal_code: Enum.at(columns, 24),

        telephone_number: Enum.at(columns, 26)
      }
    end
  end

  defp insert_batch([]), do: :ok

  defp insert_batch(batch) do
    Repo.insert_all(Provider, batch)
    IO.puts("Inserted #{length(batch)} providers...")
  end
end
