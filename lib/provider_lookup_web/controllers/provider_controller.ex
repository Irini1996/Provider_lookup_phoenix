defmodule ProviderLookupWeb.ProviderController do
  use ProviderLookupWeb, :controller
  alias ProviderLookup.Providers.ProviderSearch
  alias ProviderLookup.Providers.Provider
  alias ProviderLookup.Repo

  def index(conn, _params) do
    render(conn, :search,
      params: %{},
      providers: [],
      query_submitted: false
    )
  end

  def search(conn, params) do
    # normalize params: ensure all keys exist
    params =
      params
      |> Map.put_new("first_name", "")
      |> Map.put_new("last_name", "")
      |> Map.put_new("npi", "")
      |> Map.put_new("taxonomy", "")
      |> Map.put_new("practice_address_1", "")
      |> Map.put_new("practice_city", "")
      |> Map.put_new("practice_state", "")
      |> Map.put_new("practice_zip", "")

    # CHECK IF USER HAS TYPED ANYTHING
    query_submitted =
      params
      |> Enum.reject(fn {k,_} -> k in ["_csrf_token", "_utf8"] end)
      |> Enum.any?(fn {_k, v} -> v != "" end)

    providers =
      if query_submitted do
        ProviderSearch.search(params)
      else
        []
      end

    render(conn, :search,
      params: params,
      query_submitted: query_submitted,
      providers: providers
    )
  end

  def show(conn, %{"id" => id}) do
    provider =
      Provider
      |> Repo.get!(id)
      |> Repo.preload(provider_taxonomies: [:taxonomy])

    render(conn, :show, provider: provider)
  end
end
