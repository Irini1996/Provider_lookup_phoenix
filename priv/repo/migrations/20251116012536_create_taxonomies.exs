defmodule ProviderLookup.Repo.Migrations.CreateTaxonomies do
  use Ecto.Migration

  def change do
    create table(:taxonomies) do
      add :taxonomy_code, :string
      add :taxonomy_classification, :string
      add :taxonomy_specialization, :string

      timestamps(type: :utc_datetime, null: true)

    end

    create unique_index(:taxonomies, [:taxonomy_code])
  end
end
