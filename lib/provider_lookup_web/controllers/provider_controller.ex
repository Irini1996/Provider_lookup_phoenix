defmodule ProviderLookupWeb.ProviderController do
  use ProviderLookupWeb, :controller

  alias ProviderLookup.Providers.ProviderSearch
  alias ProviderLookup.Providers.Provider
  alias ProviderLookup.Repo

  # GET "/"
  def index(conn, _params) do
    render(conn, :search,
      params: %{},
      providers: [],
      query_submitted: false,
      page: 1,
      has_next: false,
      has_prev: false
    )
  end

  # GET "/search"
  def search(conn, incoming_params) do
    #
    # Detect if the user actually typed something
    #
    fields = [
      "first_name",
      "last_name",
      "npi",
      "taxonomy",
      "practice_address_1",
      "practice_city",
      "practice_state",
      "practice_zip"
    ]

    query_submitted =
      Enum.any?(fields, fn field ->
        value = Map.get(incoming_params, field, "")
        value != "" and value != nil
      end)

    #
    # Normalize params AFTER determining query_submitted
    #
    params =
      incoming_params
      |> Map.put_new("first_name", "")
      |> Map.put_new("last_name", "")
      |> Map.put_new("npi", "")
      |> Map.put_new("taxonomy", "")
      |> Map.put_new("practice_address_1", "")
      |> Map.put_new("practice_city", "")
      |> Map.put_new("practice_state", "")
      |> Map.put_new("practice_zip", "")
      |> Map.put_new("page", "1")

    #
    # Execute search ONLY if user typed something
    #
    %{results: providers, page: page, has_next: has_next, has_prev: has_prev} =
      if query_submitted do
        ProviderSearch.search(params)
      else
        %{results: [], page: 1, has_next: false, has_prev: false}
      end

    #
    # Render UI
    #
    render(conn, :search,
      params: params,
      query_submitted: query_submitted,
      providers: providers,
      page: page,
      has_next: has_next,
      has_prev: has_prev
    )
  end

  # GET "/providers/:id"
  def show(conn, %{"id" => id}) do
    provider =
      Provider
      |> Repo.get!(id)
      |> Repo.preload(provider_taxonomies: [:taxonomy])

    render(conn, :show, provider: provider)
  end
end
