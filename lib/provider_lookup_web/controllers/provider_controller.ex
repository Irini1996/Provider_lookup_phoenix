
# PROVIDER CONTROLLER
#
# This controller handles:
#   • Displaying the empty search page
#   • Processing search requests
#   • Rendering paginated results
#   • Showing a detailed page for a single provider
#
# It connects the browser UI with ProviderSearch and the database.


defmodule ProviderLookupWeb.ProviderController do                # Defines the ProviderController module
  use ProviderLookupWeb, :controller                             # Imports Phoenix controller behavior

  alias ProviderLookup.Providers.ProviderSearch                  # Search engine module
  alias ProviderLookup.Providers.Provider                        # Provider schema
  alias ProviderLookup.Repo                                      # Database interface



  # GET "/"
  # Renders the search page before the user submits any query.
  #This is what runs when the user first visits / without searching.
  #conn = connection to the browser.
  #_params = unused incoming parameters.


  def index(conn, _params) do                                    # "index" action receives connection + params
    render(conn, :search,                                         # Render search.html.heex template
      params: %{},                                                 # No search parameters yet
      providers: [],                                               # Empty provider list
      query_submitted: false,                                      # Indicates no search was performed
      page: 1,                                                     # Default page
      has_next: false,                                             # No pagination yet
      has_prev: false,                                             # No previous page
      total_count: 0                                               # No results
    )
  end



  # GET "/search"
  # Runs the provider search using ProviderSearch and displays results.
  #This action runs when the user sends GET /search and starts typing filters.

  def search(conn, incoming_params) do                            # Receives GET params from the search form

    # === TRIM ALL INPUTS ===
      #Loops through all parameters.
      #If value is a string → trims whitespace.
      #This prevents errors like the user typing " John ".
    trimmed =
      incoming_params                                             # All user-supplied parameters
      |> Enum.map(fn {k, v} ->                                    # Iterate over each key/value pair
        if is_binary(v), do: {k, String.trim(v)}, else: {k, v}    # Trim whitespace for string values
      end)
      |> Enum.into(%{})                                           # Convert back into a map


    # Fields we check for actual input
    fields = [                                                     # These fields determine if search is "submitted"
      "first_name",
      "last_name",
      "npi",
      "taxonomy",
      "practice_address_1",
      "practice_city",
      "practice_state",
      "practice_zip"
    ]

    # === CHECK IF USER TYPED ANYTHING ===
    #Looks through all fields.
    #If any of them is not empty → user performed a search.
    #If all are empty → don’t search.

    query_submitted =
      Enum.any?(fields, fn f -> Map.get(trimmed, f, "") != "" end)
      # If any field has non-empty content → user submitted a search


    # === NORMALIZE EMPTY FIELDS ===
    #Ensures all values exist, even if blank.
    #Without this, if a parameter is missing, Phoenix might crash or the query would fail.
    params =
      trimmed
      |> Map.put_new("first_name", "")                            # Normalize missing params to empty string
      |> Map.put_new("last_name", "")
      |> Map.put_new("npi", "")
      |> Map.put_new("taxonomy", "")
      |> Map.put_new("practice_address_1", "")
      |> Map.put_new("practice_city", "")
      |> Map.put_new("practice_state", "")
      |> Map.put_new("practice_zip", "")
      |> Map.put_new("page", "1")                                 # Ensure page parameter is always present

    # === RUN SEARCH ===
    # Pattern-matches the response from ProviderSearch
    # If the user typed something → run the real search.
    #If search fields are empty → return empty results without touching the DB.
    #This prevents unnecessary database queries.

    %{
      results: providers,                                          # List of providers for current page
      page: page,                                                  # Current page number
      total_count: total_count,                                    # Total number of matching results
      has_next: has_next,                                          # True if there is a next page
      has_prev: has_prev                                           # True if there is a previous page
    } =
      if query_submitted do                                        # Only run search if user typed something
        ProviderSearch.search(params)                              # Execute the search engine
      else
        %{results: [], page: 1, total_count: 0, has_next: false, has_prev: false}
        # If nothing typed → return empty results without querying DB
      end


    # === RENDER SEARCH RESULTS PAGE ===
    render(conn, :search,                                          # Render search.html.heex with results
      params: params,                                              # The normalized parameters
      query_submitted: query_submitted,                            # Whether a search occurred
      providers: providers,                                        # List of returned providers
      page: page,                                                  # Current page index
      has_next: has_next,                                          # Pagination indicator
      has_prev: has_prev,                                          # Pagination indicator
      total_count: total_count                                     # Total matching providers
    )
  end



  # GET "/providers/:id"
  # Shows the full details of a single provider.

  def show(conn, %{"id" => id}) do                                 # Extract provider id from URL params
    provider =
      Provider                                                      # Use Provider schema
      |> Repo.get!(id)                                             # Fetch provider by primary key
      |> Repo.preload(provider_taxonomies: [:taxonomy])            # Preload taxonomies for display

    render(conn, :show, provider: provider)                        # Render show.html.heex with the provider
  end
end

# =============================================================================
# DIFFERENCE BETWEEN ProviderController AND ProviderSearch
#
# ProviderController:
# - Handles HTTP requests coming from the browser.
# - Reads user input (search fields) from the request.
# - Cleans and normalizes parameters.
# - Decides whether to run a search or not.
# - Renders the correct HTML template with results.
# - Does NOT talk directly to the database.
#
# ProviderSearch:
# - Contains all logic for querying the database.
# - Builds SQL queries using Ecto (filters, joins, pagination).
# - Counts total results and prepares paginated data.
# - Returns structured results back to the controller.
# - Does NOT render HTML and does NOT handle user input.
#
# In short:
# Controller = input + flow control + rendering
# ProviderSearch = database filtering + pagination logic
# =============================================================================
