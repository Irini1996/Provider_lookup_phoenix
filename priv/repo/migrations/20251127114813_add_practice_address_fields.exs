defmodule ProviderLookup.Repo.Migrations.AddPracticeAddressFields do
  use Ecto.Migration

  def change do
    alter table(:providers) do
      add :practice_address_1, :string
      add :practice_address_2, :string
      add :practice_city, :string
      add :practice_state, :string
      add :practice_zip, :string
      add :practice_country, :string
    end
  end
end
#These fields extend the provider record with practice location details (street, city, state, ZIP, etc.). They’re required to support location-based searching and the provider detail page
