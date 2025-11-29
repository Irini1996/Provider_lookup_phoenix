defmodule ProviderLookup.Providers.ProviderTaxonomy do
  use Ecto.Schema
  import Ecto.Changeset

  schema "provider_taxonomies" do
    field :is_primary, :boolean, default: false


    belongs_to :provider, ProviderLookup.Providers.Provider
    belongs_to :taxonomy, ProviderLookup.Providers.Taxonomy


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(provider_taxonomy, attrs) do
    provider_taxonomy
    |> cast(attrs, [:is_primary])
    |> validate_required([:is_primary])
  end
end
