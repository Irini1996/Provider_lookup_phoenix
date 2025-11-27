defmodule ProviderLookup.Import.ProviderTaxonomyImporter do
  alias ProviderLookup.Repo
  alias ProviderLookup.CSV

  @taxonomy_cols 47..(47 + 14)
  @primary_cols 50..(50 + 14)
  @batch_size 5_000

  # -------------------------
  # Public API
  # -------------------------
  def import do
    IO.puts("[info] Loading provider cache...")
    provider_cache = load_provider_cache()

    IO.puts("[info] Loading taxonomy cache...")
    taxonomy_cache = load_taxonomy_cache()

    IO.puts("[info] Starting CSV stream...")

    priv_path = Path.join(:code.priv_dir(:provider_lookup), "data/npidata_pfile_20050523-20251109.csv")

    priv_path
    |> File.stream!([], :line)
    |> Stream.drop(1)
    |> CSV.parse_stream()
    |> Stream.map(&process_row(&1, provider_cache, taxonomy_cache))
    |> Stream.reject(&is_nil/1)
    |> Stream.chunk_every(@batch_size)
    |> Stream.each(&insert_batch/1)
    |> Stream.run()

    IO.puts("[info] Import finished!")
  end

  # -------------------------
  # Provider Cache
  # -------------------------
  defp load_provider_cache do
    sql = """
      SELECT npi_number::text, id
      FROM providers
    """

    Repo.query!(sql).rows
    |> Enum.into(%{}, fn [npi, id] -> {npi, id} end)
  end

  # -------------------------
  # Taxonomy Cache
  # -------------------------
  defp load_taxonomy_cache do
    sql = """
      SELECT taxonomy_code, id
      FROM taxonomies
    """

    Repo.query!(sql).rows
    |> Enum.into(%{}, fn [code, id] -> {code, id} end)
  end

  # -------------------------
  # Process a single CSV row
  # -------------------------
  defp process_row(row, provider_cache, taxonomy_cache) do
    npi = Enum.at(row, 0)
    provider_id = provider_cache[npi]

    if provider_id do
      taxonomies =
        Enum.zip(@taxonomy_cols, @primary_cols)
        |> Enum.map(fn {tax_col, prim_col} ->
          code = Enum.at(row, tax_col)
          primary = Enum.at(row, prim_col)

          with true <- code not in [nil, "", " "],
               taxonomy_id when not is_nil(taxonomy_id) <- taxonomy_cache[code] do
            %{
              provider_id: provider_id,
              taxonomy_id: taxonomy_id,
              is_primary: primary == "Y",
              inserted_at: DateTime.utc_now(),
              updated_at: DateTime.utc_now()
            }
          else
            _ -> nil
          end
        end)
        |> Enum.reject(&is_nil/1)

      taxonomies
    else
      nil
    end
  end

  # -------------------------
  # Batch Insert
  # -------------------------
  defp insert_batch(batch) do
    flat = List.flatten(batch)

    Repo.insert_all(
      "provider_taxonomies",
      flat,
      on_conflict: :nothing
    )
  end
end
