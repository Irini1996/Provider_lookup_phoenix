defmodule ProviderLookup.Repo.Migrations.CreateProviders do
  use Ecto.Migration

  def change do
    create table(:providers) do
      add :npi_number, :string
      add :enumeration_type, :string
      add :first_name, :string
      add :last_name, :string
      add :organization_name, :string
      add :address_purpose, :string
      add :address_line, :string
      add :city, :string
      add :state, :string
      add :postal_code, :string
      add :country_code, :string
      add :telephone_number, :string
      add :fax_number, :string

      timestamps(type: :utc_datetime)
    end
  end
end
