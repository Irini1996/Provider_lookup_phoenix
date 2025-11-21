defmodule ProviderLookup.Providers.Taxonomy do
  use Ecto.Schema
  import Ecto.Changeset

  schema "taxonomies" do
    field :taxonomy_code, :string
    field :taxonomy_classification, :string
    field :taxonomy_specialization, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(taxonomy, attrs) do
    taxonomy
    |> cast(attrs, [:taxonomy_code, :taxonomy_classification, :taxonomy_specialization])
    |> validate_required([:taxonomy_code, :taxonomy_classification, :taxonomy_specialization])
  end
end
