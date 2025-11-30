defmodule ProviderLookup.Providers.ProviderSearch do
  import Ecto.Query
  alias ProviderLookup.Repo
  alias ProviderLookup.Providers.{Provider, ProviderTaxonomy, Taxonomy}

  @page_size 50

  def search(params) do
    page =
      case Map.get(params, "page") do
        nil -> 1
        "" -> 1
        p -> String.to_integer(p)
      end

    offset = (page - 1) * @page_size

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
          practice_address_1: p.practice_address_1,
          practice_city: p.practice_city,
          practice_state: p.practice_state,
          practice_zip: p.practice_zip,
          taxonomy_names:
            fragment(
              "array_remove(array_agg(COALESCE(? || ' ' || ?, '')), '')",
              t.taxonomy_classification,
              t.taxonomy_specialization
            )
        }

    query =
      base
      |> maybe_like(:first_name, params["first_name"])
      |> maybe_like(:last_name,  params["last_name"])
      |> maybe_eq(:npi_number,   params["npi"])
      |> maybe_like(:practice_address_1, params["practice_address_1"])
      |> maybe_like(:practice_city,       params["practice_city"])
      |> maybe_like(:practice_state,      params["practice_state"])
      |> maybe_like(:practice_zip,        params["practice_zip"])
      |> maybe_taxonomy(params["taxonomy"])
      |> limit(@page_size)
      |> offset(^offset)

    %{
      results: Repo.all(query),
      page: page
    }
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
    where(query, [_, _, t],
      ilike(t.taxonomy_code, ^"%#{taxonomy}%") or
      ilike(t.taxonomy_classification, ^"%#{taxonomy}%") or
      ilike(t.taxonomy_specialization, ^"%#{taxonomy}%")
    )
  end
end
