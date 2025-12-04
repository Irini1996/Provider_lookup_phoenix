# PROVIDER SEARCH MODULE
#
# This module implements the complete server-side search engine for providers.
# It dynamically builds Ecto queries based on user-supplied filters such as
# name, NPI, practice address, and taxonomy. The search supports:
#
#   • Flexible partial matching using ILIKE
#   • Taxonomy-based filtering through join tables
#   • Pagination (page size = 50)
#   • Aggregation of taxonomy names per provider
#   • Accurate total-count calculation for UI pagination
#
# It returns a structured map containing the results, the current page,
# the total count, and flags (has_next / has_prev) used by the UI.


#Ecto is the database toolkit used in Elixir and Phoenix applications.
#It helps your app communicate with the database safely and efficiently.
#It provides schemas, changesets, and queries to structure and validate data.
#Think of it as the bridge between your Elixir code and your database.

#Queries are instructions you send to the database to ask for specific data.
#They tell the database what information you want—like filtering, sorting, or counting.
#In Ecto, queries are written using Elixir instead of raw SQL.
#They allow your app to read, search, and manipulate data in a clean and safe way.

defmodule ProviderLookup.Providers.ProviderSearch do                # Search engine module for provider lookup
  import Ecto.Query                                                 # Imports query macros (from, where, join, etc.)
  alias ProviderLookup.Repo                                         # Repo used to execute all DB queries
  alias ProviderLookup.Providers.{Provider, ProviderTaxonomy, Taxonomy}  # Aliases for schema modules

  @page_size 50                                                     # Number of search results per page

#This is the main function. It receives search parameters (first_name, npi, taxonomy, etc.) and returns filtered results.
  def search(params) do                                             # Main entry point for executing a search

    # === PAGE HANDLING ===
#Reads the "page" parameter.
#If it’s missing or empty, defaults to page 1.
#Otherwise converts the string "3" → integer 3.
    page =
      case Map.get(params, "page") do                               # Read the "page" parameter from params
        nil -> 1                                                    # If missing, default to page 1
        "" -> 1                                                     # If empty, also default to page 1
        p -> String.to_integer(p)                                   # Otherwise convert it to an integer
      end

    offset = (page - 1) * @page_size                                # Calculate how many rows to skip for pagination



    # === BASE QUERY (before applying filters) ===
    #This query:
    #Starts from the providers table (p).
    #Left-joins the table that links providers → taxonomies (provider_taxonomies).
    #Then joins the actual taxonomy table.
    #Uses left join so providers still appear even if they have no taxonomy.


    base =
      from p in Provider,                                           # Start query from providers table (alias p)
        left_join: pt in ProviderTaxonomy,                          # Left join provider_taxonomies (alias pt)
          on: pt.provider_id == p.id,                               # Join condition: provider → provider_taxonomies
        left_join: t in Taxonomy,                                   # Left join taxonomy table (alias t)
          on: pt.taxonomy_id == t.id                                # Join condition: provider_taxonomies → taxonomy

    # === APPLY FILTERS BASED ON USER INPUT ===
    #Each helper (maybe_like, maybe_eq, maybe_taxonomy) checks:
    #“Did the user type something for this field?”
    #If yes, add a WHERE condition.
    #If no, skip the filter entirely.


    filtered =
      base
      |> maybe_like(:first_name, params["first_name"])              # Filter providers by first name (case-insensitive)
      |> maybe_like(:last_name, params["last_name"])                # Filter by last name (ILIKE)
      |> maybe_eq(:npi_number, params["npi"])                       # Exact NPI match
      |> maybe_like(:practice_address_1, params["practice_address_1"]) # Filter by practice street
      |> maybe_like(:practice_city, params["practice_city"])        # Filter by city
      |> maybe_like(:practice_state, params["practice_state"])      # Filter by state
      |> maybe_like(:practice_zip, params["practice_zip"])          # Filter by ZIP code
      |> maybe_taxonomy(params["taxonomy"])                         # Filter by taxonomy fields


    #
    # === TOTAL COUNT ===
    #The total number of matching results to calculate pages.
    total_count =
      filtered
      |> exclude(:group_by)                                         # Remove any group_by from the query
      |> exclude(:select)                                           # Remove any select statement to avoid conflicts
      |> select([p, _, _], count(p.id))                             # Replace select with COUNT(*)
      |> Repo.one()                                                 # Execute query and return a single integer


    #
    # === PAGINATED RESULT QUERY ===
    #Because later we use array_agg() to group taxonomy names into a list for each provider.
    #SQL requires grouping whenever you aggregate.
    paged_query =
      filtered
      |> group_by([p, _, _], p.id)                                  # Group by provider id for array_agg
      |> select([p, _, t], %{                                       # Select output fields #Selecting each field we want to show in the results table.
        id: p.id,                                                   # Provider ID
        npi_number: p.npi_number,                                   # Provider NPI
        first_name: p.first_name,                                   # First name
        last_name: p.last_name,                                     # Last name
        practice_address_1: p.practice_address_1,                   # Practice street
        practice_city: p.practice_city,                             # Practice city
        practice_state: p.practice_state,                           # Practice state
        practice_zip: p.practice_zip,                               # Practice ZIP code
        taxonomy_names:                                             # List of taxonomies for each provider
          fragment(                                                 # Raw SQL fragment for array aggregation
            "array_remove(array_agg(COALESCE(? || ' ' || ?, '')), '')",
            t.taxonomy_classification,                              # Classification (e.g., "Internal Medicine")
            t.taxonomy_specialization                               # Specialization (e.g., "Cardiovascular Disease")
          )
      })
      |> limit(@page_size)                                          # LIMIT clause for pagination
      |> offset(^offset)                                            # OFFSET clause for pagination


    #
    # === EXECUTE QUERY ===
    #
    results = Repo.all(paged_query)                                 # Fetch current page of results from DB


    #
    # === STRUCTURE RETURNED TO CONTROLLER ===
    #
    %{
      results: results,                                             # The list of providers returned for this page
      page: page,                                                   # Current page number
      total_count: total_count,                                     # Total matching results
      has_next: page * @page_size < total_count,                    # Whether a next page exists
      has_prev: page > 1                                            # Whether a previous page exists
    }
  end


  # maybe_like: applies an ILIKE filter only if value is not empty
  defp maybe_like(query, _field, ""), do: query                     # If param empty → no filter
  defp maybe_like(query, field, value) do                           # Otherwise apply a case-insensitive filter
    clean = String.trim(value || "")                                # Remove whitespace

    if clean == "" do                                               # If empty after trimming → skip
      query
    else
      where(query, [p, _, _], ilike(field(p, ^field), ^"%#{clean}%")) # WHERE field ILIKE '%value%'
    end
  end


  # maybe_eq: applies an exact-match filter if value is not empty
  defp maybe_eq(query, _field, ""), do: query                       # Skip if no value
  defp maybe_eq(query, field, value) do                             # Exact match
    where(query, [p, _, _], field(p, ^field) == ^value)
  end


  # maybe_taxonomy: searches taxonomy_code, classification, specialization
  defp maybe_taxonomy(query, ""), do: query                         # Skip if no taxonomy filter
  defp maybe_taxonomy(query, taxonomy) do                           # Apply taxonomy-related filters
    where(query, [_, _, t],
      ilike(t.taxonomy_code, ^"%#{taxonomy}%") or                   # Match taxonomy code
      ilike(t.taxonomy_classification, ^"%#{taxonomy}%") or         # Match classification
      ilike(t.taxonomy_specialization, ^"%#{taxonomy}%")            # Match specialization
    )
  end
end
