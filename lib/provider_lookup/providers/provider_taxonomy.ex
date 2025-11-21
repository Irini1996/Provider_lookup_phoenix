defmodule ProviderLookup.Providers.ProviderTaxonomy do
  use Ecto.Schema
  import Ecto.Changeset

  schema "provider_taxonomies" do
    field :is_primary, :boolean, default: false
    field :provider_id, :id
    field :taxonomy_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(provider_taxonomy, attrs) do
    provider_taxonomy
    |> cast(attrs, [:is_primary])
    |> validate_required([:is_primary])
  end
end
