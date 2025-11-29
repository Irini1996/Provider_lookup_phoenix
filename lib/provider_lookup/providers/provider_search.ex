defmodule ProviderLookup.Providers.ProviderSearch do
  import Ecto.Query
  alias ProviderLookup.Repo
  alias ProviderLookup.Providers.{Provider, ProviderTaxonomy, Taxonomy}

  def search(params) do
    base =
      from p in Provider,
        left_join: pt in ProviderTaxonomy, on: pt.provider_id == p.id,
        left_join: t in Taxonomy, on: pt.taxonomy_id == t.id,
        group_by: p.id,
        select: %{
          id: p.id,
          npi_number: p.npi_number,
          first_name: p.first_name,
          last_name: p.last_name,
          city: p.city,
          state: p.state,
          taxonomy_names:
            fragment(
              "array_remove(array_agg(COALESCE(? || ' ' || ?, '')), '')",
              t.taxonomy_classification,
              t.taxonomy_specialization
            )
        }

    base
    |> maybe_like(:first_name, params["first_name"])
    |> maybe_like(:last_name,  params["last_name"])
    |> maybe_eq(:npi_number,   params["npi"])
    |> maybe_like(:city,       params["city"])
    |> maybe_like(:state,      params["state"])
    |> maybe_like(:postal_code, params["zip"])
    |> maybe_taxonomy(params["taxonomy"])
    |> limit(50)
    |> Repo.all()
  end

  # HELPERS
  defp maybe_like(query, _field, ""), do: query
  defp maybe_like(query, field, value) do
    where(query, [p, _, _], ilike(field(p, ^field), ^"%#{value}%"))
  end

  defp maybe_eq(query, _field, ""), do: query
  defp maybe_eq(query, field, value) do
    where(query, [p, _, _], field(p, ^field) == ^value)
  end

  defp maybe_taxonomy(query, ""), do: query
  defp maybe_taxonomy(query, taxonomy) do
    where(query, [_, pt, t], ilike(t.taxonomy_code, ^"%#{taxonomy}%"))
  end
end
