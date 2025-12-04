#The Taxonomy schema contains the NUCC taxonomy definitions.
#Each taxonomy record stores a taxonomy code, its classification, and its specialization.
#This table functions as the reference dictionary that describes the type of services a provider is qualified to perform

defmodule ProviderLookup.Providers.Taxonomy do              # Defines the Taxonomy module
  use Ecto.Schema                                           # Enables Ecto schema functionality
  import Ecto.Changeset                                     # Enables building/validating changesets

  schema "taxonomies" do                                    # Maps this schema to the "taxonomies" table

    field :taxonomy_code, :string                           # NUCC taxonomy code (e.g., "207Q00000X")
    field :taxonomy_classification, :string                 # Main classification (e.g., "Family Medicine")
    field :taxonomy_specialization, :string                 # Sub-specialization (optional in NUCC)

    has_many :provider_taxonomies,                          # A taxonomy can be linked by many providers
             ProviderLookup.Providers.ProviderTaxonomy

    has_many :providers,                                    # Shortcut: access providers through join table
             through: [:provider_taxonomies, :provider]

    timestamps(type: :utc_datetime)                         # Inserts inserted_at / updated_at timestamps
  end

  def changeset(taxonomy, attrs) do                         ## Builds/validates taxonomy changeset
    taxonomy
    |> cast(attrs, [:taxonomy_code, :taxonomy_classification, :taxonomy_specialization])   ## Chooses which fields may be updated
    |> validate_required([:taxonomy_code, :taxonomy_classification, :taxonomy_specialization])    ## Ensures all fields are present
  end
end
