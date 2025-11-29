defmodule ProviderLookup.Repo.Migrations.AddSearchIndexes do
  use Ecto.Migration

  def change do
    create index(:providers, [:npi_number])
    create index(:providers, [:first_name])
    create index(:providers, [:last_name])
    create index(:providers, [:address_line])
    create index(:providers, [:city])
    create index(:providers, [:state])
    create index(:providers, [:postal_code])

  end
end
