defmodule ProviderLookup.Providers.ProviderSearch do        # Search engine module
  import Ecto.Query                                          # Import Ecto query macros
  alias ProviderLookup.Repo                                  # Repo used to execute queries
  alias ProviderLookup.Providers.{Provider, ProviderTaxonomy, Taxonomy}

  @page_size 50                                              # Number of results per page

  def search(params) do                                      # Entry point for all searches
    #
    # === READ & NORMALIZE PAGE NUMBER ===
    #
    page =
      case Map.get(params, "page") do                        # Read page parameter
        nil -> 1                                             # Default to 1 if missing
        "" -> 1                                              # Default to 1 if empty
        p -> String.to_integer(p)                            # Convert string to integer
      end

    offset = (page - 1) * @page_size                         # OFFSET = (page - 1) * limit

    #
    # === BASE QUERY (NO SELECT YET) ===
    # Used once for total_count and once for actual results
    #
    base =
      from p in Provider,                                    # Start from providers table
        left_join: pt in ProviderTaxonomy,                   # Join provider_taxonomies
          on: pt.provider_id == p.id,
        left_join: t in Taxonomy,                            # Join taxonomy table
          on: pt.taxonomy_id == t.id

    #
    # === APPLY FILTERS TO THE BASE QUERY ===
    #
    filtered =
      base
      |> maybe_like(:first_name, params["first_name"])       # Filter by first name (ILIKE)
      |> maybe_like(:last_name, params["last_name"])         # Filter by last name
      |> maybe_eq(:npi_number, params["npi"])                # Exact match for NPI
      |> maybe_like(:practice_address_1, params["practice_address_1"])
      |> maybe_like(:practice_city, params["practice_city"])
      |> maybe_like(:practice_state, params["practice_state"])
      |> maybe_like(:practice_zip, params["practice_zip"])
      |> maybe_taxonomy(params["taxonomy"])                  # Filter taxonomy fields

    #
    # === CORRECT TOTAL COUNT (NO GROUP BY / NO LIMIT) ===
    # Required for proper pagination.
    #
    total_count =
      filtered
      |> exclude(:group_by)                                   # Remove group_by (otherwise count breaks)
      |> exclude(:select)                                    # Remove previous select
      |> select([p, _, _], count(p.id))                      # Simple COUNT(*)
      |> Repo.one()                                          # Returns exactly 1 integer

    #
    # === MAIN PAGINATED QUERY ===
    #
    paged_query =
      filtered
      |> group_by([p, _, _], p.id)                           # Needed for array_agg
      |> select([p, _, t], %{                                # Select the fields for each result row
        id: p.id,
        npi_number: p.npi_number,
        first_name: p.first_name,
        last_name: p.last_name,
        practice_address_1: p.practice_address_1,
        practice_city: p.practice_city,
        practice_state: p.practice_state,
        practice_zip: p.practice_zip,
        taxonomy_names:
          fragment(                                          # Aggregate taxonomy info into array
            "array_remove(array_agg(COALESCE(? || ' ' || ?, '')), '')",
            t.taxonomy_classification,
            t.taxonomy_specialization
          )
      })
      |> limit(@page_size)                                   # LIMIT for pagination
      |> offset(^offset)                                     # OFFSET for pagination

    #
    # === EXECUTE ===
    #
    results = Repo.all(paged_query)                          # Fetch only the current page

    #
    # === STRUCT RETURNED TO CONTROLLER ===
    #
    %{
      results: results,                                      # This page’s result set
      page: page,                                            # Current page number
      total_count: total_count,                              # Total rows matching filters
      has_next: page * @page_size < total_count,             # True if there's another page
      has_prev: page > 1                                     # True if page > 1
    }
  end

  # === Helper: ILIKE filter ===
  defp maybe_like(query, _field, ""), do: query              # Skip when value is empty
  defp maybe_like(query, field, value) do
    where(query, [p, _, _], ilike(field(p, ^field), ^"%#{value}%"))
  end

  # === Helper: exact match ===
  defp maybe_eq(query, _field, ""), do: query
  defp maybe_eq(query, field, value) do
    where(query, [p, _, _], field(p, ^field) == ^value)
  end

  # === Helper: taxonomy ===
  defp maybe_taxonomy(query, ""), do: query
  defp maybe_taxonomy(query, taxonomy) do
    where(query, [_, _, t],
      ilike(t.taxonomy_code, ^"%#{taxonomy}%") or
      ilike(t.taxonomy_classification, ^"%#{taxonomy}%") or
      ilike(t.taxonomy_specialization, ^"%#{taxonomy}%")
    )
  end
end
