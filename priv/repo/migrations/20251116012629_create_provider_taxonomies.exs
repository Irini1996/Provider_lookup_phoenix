defmodule ProviderLookup.Repo.Migrations.CreateProviderTaxonomies do
  use Ecto.Migration

  def change do
    create table(:provider_taxonomies) do
      add :is_primary, :boolean, default: false, null: false
      add :provider_id, references(:providers, on_delete: :nothing)
      add :taxonomy_id, references(:taxonomies, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:provider_taxonomies, [:provider_id])
    create index(:provider_taxonomies, [:taxonomy_id])
  end
end
