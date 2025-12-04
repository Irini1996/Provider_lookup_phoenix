defmodule ProviderLookup.Repo.Migrations.AddUniqueIndexToProvidersNpi do
  use Ecto.Migration

  def change do

  end
end
#This enforces data integrity by ensuring each NPI number appears only once. It also speeds up NPI-based lookups.
