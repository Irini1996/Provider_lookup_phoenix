#The ProviderTaxonomy schema is the join table that connects providers with their taxonomies.
#A provider may have multiple taxonomies, and this table stores those relationships, including which taxonomy is marked as the primary one.

defmodule ProviderLookup.Providers.ProviderTaxonomy do          # Module defining the join table schema
  use Ecto.Schema                                               # Enables Ecto schema behavior
  import Ecto.Changeset                                         # Allows validations and casting

  schema "provider_taxonomies" do                               # Maps schema to "provider_taxonomies" table

    field :is_primary, :boolean, default: false                 # Indicates if this taxonomy is the primary one

    belongs_to :provider,                                       # FK: links record to a provider
               ProviderLookup.Providers.Provider

    belongs_to :taxonomy,                                       # FK: links record to a taxonomy entry
               ProviderLookup.Providers.Taxonomy

    timestamps(type: :utc_datetime)                             # Auto-managed inserted_at / updated_at fields
  end

  @doc false
  def changeset(provider_taxonomy, attrs) do                    # Builds and validates a changeset
    provider_taxonomy
    |> cast(attrs, [:is_primary])                               # Only :is_primary can be updated directly
    |> validate_required([:is_primary])                         # Ensures the boolean value is always present
  end
end
