defmodule ProviderLookup.Import.ProviderImporter do     # Define the module responsible for importing provider data
  alias ProviderLookup.Repo                             # Alias for the Repo module (database access)
  alias ProviderLookup.Providers.Provider               # Alias for the Provider schema
  require Logger                                         # Allow usage of Logger for logging messages

  @batch_size 4000                                       # Number of records inserted per batch

  def import_providers do                                # Main function that starts the provider import process
    file_path = priv_path("data/npidata_pfile_20050523-20251109.csv")  # Build full path to the CSV file

    file_path
    |> File.stream!([], :line)                           # Read the file line-by-line as a lazy stream
    |> Stream.drop(1)                                    # Skip the header row from the CSV
    |> Stream.map(&parse_csv_line/1)                     # Parse each CSV line into a map
    |> Stream.chunk_every(@batch_size)                   # Split parsed records into batches of @batch_size
    |> Enum.reduce(0, fn batch, acc ->                   # Process each batch and keep a running count
      insert_batch(batch)                                # Insert this batch into the database
      count = acc + length(batch)                        # Add batch size to total count
      Logger.info("Inserted #{count} providers...")      # Log progress message
      count                                             # BUG: returns a non-existent variable (should be `count`)
    end)
  end

  defp priv_path(relative) do                            # Build absolute path to a priv/ file
    :provider_lookup                                     # The OTP application name
    |> :code.priv_dir()                                  # Get the priv directory for the application
    |> Path.join(relative)                               # Append the relative path (CSV location)
  end

  # Adjust column indices based on your CSV
  defp parse_csv_line(line) do                           # Parse one CSV row into a map
    [npi, type, first, last, org, purpose, addr, city, state, zip, country, phone, fax | _] =
      line |> String.trim() |> String.split(",", parts: 20)  # Trim whitespace and split CSV into columns
      now = DateTime.utc_now() |> DateTime.truncate(:second) # Get current timestamp (no milliseconds)

    %{
      npi_number: npi,                                   # Assign NPI number
      enumeration_type: type,                            # Assign enumeration type
      first_name: first,                                 # Assign first name
      last_name: last,                                   # Assign last name
      organization_name: org,                            # Assign organization name
      address_purpose: purpose,                          # Assign address purpose
      address_line: addr,                                # Assign street address
      city: city,                                        # Assign city
      state: state,                                      # Assign state
      postal_code: zip,                                  # Assign ZIP code
      country_code: country,                             # Assign country code
      telephone_number: phone,                           # Assign phone number
      fax_number: fax,                                   # Assign fax number
      inserted_at: now,                                  # Set inserted_at timestamp
      updated_at: now                                    # Set updated_at timestamp
    }
  end

  defp insert_batch(batch) do                            # Insert a batch of provider records
    Repo.insert_all(Provider, batch, on_conflict: :nothing)  # Insert and ignore conflicts if row exists
  end
end                                                     # End of module
## It reads an NPI CSV file, parses every provider entry, and bulk-inserts them into the database with progress logging.
