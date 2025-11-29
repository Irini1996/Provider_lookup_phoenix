defmodule ProviderLookup.Import.ProviderImporter do
  NimbleCSV.define(ProviderLookup.Import.ProviderImporter.CSV, separator: ",", escape: "\"")
  alias ProviderLookup.Repo
  alias ProviderLookup.Providers.Provider
  require Logger

  @batch_size 4000

  # ----------------------------------------------------------
  # PUBLIC ENTRYPOINT
  # ----------------------------------------------------------
  def import_providers do
    file_path = priv_path("data/npidata_pfile_20050523-20251109.csv")

    file_path
    |> File.stream!([], :line)
    |> Stream.drop(1)
    |> ProviderLookup.Import.ProviderImporter.CSV.parse_stream()
    |> Stream.map(&build_provider_map/1)
    |> Stream.reject(&is_nil/1)
    |> Stream.chunk_every(@batch_size)
    |> Enum.reduce(0, fn batch, acc ->
      insert_batch(batch)
      total = acc + length(batch)
      Logger.info("Inserted #{total} providers...")
      total
    end)
  end

  defp priv_path(relative) do
    :provider_lookup
    |> :code.priv_dir()
    |> Path.join(relative)
  end

  # ----------------------------------------------------------
  # BUILD PROVIDER MAP
  # ----------------------------------------------------------
  def build_provider_map(fields) when is_list(fields) do
    npi = Enum.at(fields, 0)

    # Skip invalid rows
    if is_nil(npi) or npi == "" do
      nil
    else
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      %{
        npi_number: npi,
        enumeration_type: Enum.at(fields, 1),

        # Names / organisation
        organization_name: Enum.at(fields, 4),
        last_name:         Enum.at(fields, 5),
        first_name:        Enum.at(fields, 6),

        # MAILING ADDRESS — EXACT CSV INDEXES
        address_purpose: "MAILING",
        address_line:    Enum.at(fields, 20),
        city:            Enum.at(fields, 22),
        state:           Enum.at(fields, 23),
        postal_code:     Enum.at(fields, 24),

        country_code:      Enum.at(fields, 25),
        telephone_number:  Enum.at(fields, 26),
        fax_number:        Enum.at(fields, 27),

        inserted_at: now,
        updated_at: now
      }
    end
  end

  # ----------------------------------------------------------
  # INSERT BATCH
  # ----------------------------------------------------------
  defp insert_batch(batch) do
    Repo.insert_all(Provider, batch, on_conflict: :nothing)
  end
end
