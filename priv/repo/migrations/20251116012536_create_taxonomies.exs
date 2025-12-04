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
#This creates the taxonomy reference table. It holds the NUCC taxonomy codes/classifications/specializations so the system can match each provider to the correct taxonomy definitions
