#The Provider schema represents the core NPI provider record. It stores all identifying information such as NPI number, enumeration type (individual or organization),
#personal or organizational name, and the mailing address defined by NPPES.
#It also includes the full practice location fields (practice address, city, state, ZIP, country, phone),
#which are required for geographical searches and for displaying a complete provider profile
defmodule ProviderLookup.Providers.Provider do        # Defines the Provider module
  use Ecto.Schema                                     # Enables Ecto schema behavior
  import Ecto.Changeset                               # Allows building changesets

  schema "providers" do                               # Maps this schema to the "providers" DB table

    field :npi_number, :string                        # NPI: unique provider identifier (10 digits)
    field :enumeration_type, :string                  # "1" = Individual, "2" = Organization
    field :first_name, :string                        # First name for individuals
    field :last_name, :string                         # Last name for individuals
    field :organization_name, :string                 # Business/organization name

    field :address_purpose, :string                   # Indicates address purpose ("MAILING")
    field :address_line, :string                      # Mailing address street line
    field :city, :string                              # Mailing address city
    field :state, :string                             # Mailing address state (2-letter code)
    field :postal_code, :string                       # Mailing ZIP or ZIP+4
    field :country_code, :string                      # Country code (e.g., "US")
    field :telephone_number, :string                  # Mailing phone number
    field :fax_number, :string                        # Mailing fax number

    field :practice_address_1, :string                # Practice location primary street line
    field :practice_address_2, :string                # Practice location secondary line (suite/floor)
    field :practice_city, :string                     # Practice city
    field :practice_state, :string                    # Practice state
    field :practice_zip, :string                      # Practice ZIP code
    field :practice_country, :string                  # Practice country code
    field :practice_phone, :string                    # Practice phone number

    has_many :provider_taxonomies,                    # A provider can have many taxonomy links
             ProviderLookup.Providers.ProviderTaxonomy

    has_many :taxonomies,                             # Shortcut association to taxonomy records
             through: [:provider_taxonomies, :taxonomy]

    timestamps(type: :utc_datetime)                   # Auto-generated inserted_at & updated_at
  end


  @doc false
  def changeset(provider, attrs) do                    ## Builds a changeset for Provider updates/inserts
    provider
    |> cast(attrs, [                                    # # Select which fields can be updated
      :npi_number, :enumeration_type, :first_name, :last_name,
      :organization_name,
      :address_purpose, :address_line, :city, :state, :postal_code,
      :country_code, :telephone_number, :fax_number
    ])
  end
end
