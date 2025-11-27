defmodule ProviderLookup.Import.TaxonomyImporter do
  alias ProviderLookup.Repo
  alias ProviderLookup.Providers.Taxonomy
  require Logger

  @batch_size 1000

  def import_taxonomies do
    file_path = priv_path("data/taxonomies.csv")

    file_path
    |> File.stream!([], :line)
    |> Stream.drop(1)                   # Skip header row
    |> Stream.map(&parse_csv_line/1)
    |> Stream.chunk_every(@batch_size)
    |> Enum.reduce(0, fn batch, acc ->
      insert_batch(batch)
      count = acc + length(batch)
      Logger.info("Inserted #{count} taxonomies...")
      count
    end)
  end

  defp priv_path(relative) do
    :provider_lookup
    |> :code.priv_dir()
    |> Path.join(relative)
  end

  # Parse each CSV line into a map matching the Taxonomy schema
  defp parse_csv_line(line) do
    [code, classification, specialization | _] =
      line
      |> String.trim()
      |> String.split(",", parts: 4)

    now = DateTime.utc_now() |> DateTime.truncate(:second)

    %{
      taxonomy_code: code,
      taxonomy_classification: classification,
      taxonomy_specialization: specialization,
      inserted_at: now,
      updated_at: now
    }
  end

  # Insert batch using fast insert_all
  defp insert_batch(batch) do
    Repo.insert_all(Taxonomy, batch, on_conflict: :nothing)
  end
end
#This module reads a taxonomy CSV file, parses each row into a taxonomy record, and bulk-inserts them into the database.
#It processes the file efficiently in batches to handle large datasets.
#Throughout the process, it logs progress so you can track how many taxonomies were imported.
