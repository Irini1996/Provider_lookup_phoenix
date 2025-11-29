defmodule ProviderLookup.Providers do
  import Ecto.Query, warn: false
  alias ProviderLookup.Repo

  alias ProviderLookup.Providers.{
    Provider,
    Taxonomy,
    ProviderTaxonomy
  }

  # ---------------------------------------------------------
  # BASIC QUERIES
  # ---------------------------------------------------------

  def get_provider!(id) do
    Provider
    |> Repo.get!(id)
    |> Repo.preload(:taxonomies)
  end

  def list_providers do
    Repo.all(Provider)
  end

  def list_taxonomies do
    Repo.all(Taxonomy)
  end

  # ---------------------------------------------------------
  # MAIN SEARCH FUNCTION
  # ---------------------------------------------------------

  # No filters → return empty list (avoid loading entire DB)
  def search_providers(filters) when filters == %{} do
    []
  end

  def search_providers(filters) do
    Provider
    |> filter_name(filters["name"])
    |> filter_npi(filters["npi"])
    |> filter_city(filters["city"])
    |> filter_state(filters["state"])
    |> filter_postal(filters["postal_code"])
    |> filter_taxonomy(filters["taxonomy"])
    |> limit_result(filters["limit"])
    |> filter_address(filters["address"])
    |> Repo.all()
    |> Repo.preload(:taxonomies)
  end

  # ---------------------------------------------------------
  # FILTERS
  # ---------------------------------------------------------

  # Name filter
  defp filter_name(query, nil), do: query
  defp filter_name(query, ""),  do: query
  defp filter_name(query, name) do
    like = "%#{name}%"

    from p in query,
      where:
           ilike(p.first_name, ^like) or
           ilike(p.last_name, ^like) or
           ilike(p.organization_name, ^like)
  end

  # NPI filter
  defp filter_npi(query, nil), do: query
  defp filter_npi(query, ""),  do: query
  defp filter_npi(query, npi) do
    from p in query, where: p.npi_number == ^npi
  end

  # City filter
  defp filter_city(query, nil), do: query
  defp filter_city(query, ""),  do: query
  defp filter_city(query, city) do
    like = "%#{city}%"
    from p in query, where: ilike(p.city, ^like)
  end

  # State filter
  defp filter_state(query, nil), do: query
  defp filter_state(query, ""),  do: query
  defp filter_state(query, state) do
    from p in query, where: p.state == ^String.upcase(state)
  end

  # ZIP filter
  defp filter_postal(query, nil), do: query
  defp filter_postal(query, ""),  do: query
  defp filter_postal(query, zip) do
    from p in query, where: p.postal_code == ^zip
  end

  defp filter_address(query, nil), do: query
defp filter_address(query, ""), do: query

defp filter_address(query, value) do
  v = "%#{value}%"

  from p in query,
    where:
      ilike(p.practice_address_1, ^v) or
      ilike(p.practice_address_2, ^v) or
      ilike(p.practice_city, ^v) or
      ilike(p.practice_state, ^v) or
      ilike(p.practice_zip, ^v)
end


  # Taxonomy search in classification OR specialization
  defp filter_taxonomy(query, nil), do: query
  defp filter_taxonomy(query, ""),  do: query

  defp filter_taxonomy(query, taxonomy) do
    like = "%#{taxonomy}%"

    from p in query,
      join: pt in ProviderTaxonomy, on: pt.provider_id == p.id,
      join: t in Taxonomy, on: t.id == pt.taxonomy_id,
      where:
           ilike(t.taxonomy_specialization, ^like) or
           ilike(t.taxonomy_classification, ^like)
  end

  # ---------------------------------------------------------
  # LIMIT HANDLING — SAFE & ERROR-PROOF
  # ---------------------------------------------------------

  # Default limit when no value provided
  defp limit_result(query, nil), do: from(p in query, limit: 100)
  defp limit_result(query, ""),  do: from(p in query, limit: 100)

  defp limit_result(query, limit) do
    case Integer.parse(limit) do
      {num, _} when num > 0 and num < 1000 ->
        from(p in query, limit: ^num)

      _ ->
        from(p in query, limit: 100)
    end
  end
end
