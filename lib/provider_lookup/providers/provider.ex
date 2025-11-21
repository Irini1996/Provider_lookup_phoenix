defmodule ProviderLookup.Providers.Provider do   # Defines a module (like a class in Django)
  use Ecto.Schema   # Enables Ecto schema features for defining database tables
  import Ecto.Changeset  # Enables Ecto schema features for defining database tables

  schema "providers" do   # Enables Ecto schema features for defining database tables
    field :npi_number, :string   # Enables Ecto schema features for defining database tables
    field :enumeration_type, :string
    field :first_name, :string
    field :last_name, :string
    field :organization_name, :string
    field :address_purpose, :string
    field :address_line, :string
    field :city, :string
    field :state, :string
    field :postal_code, :string
    field :country_code, :string
    field :telephone_number, :string
    field :fax_number, :string

    timestamps(type: :utc_datetime)  # Automatically adds inserted_at and updated_at (UTC format)
  end

  @doc false   # Marks the function as internal
  def changeset(provider, attrs) do  # Defines a function to validate incoming data
    provider
    |> cast(attrs, [:npi_number, :enumeration_type, :first_name, :last_name, :organization_name, :address_purpose, :address_line, :city, :state, :postal_code, :country_code, :telephone_number, :fax_number])
    |> validate_required([:npi_number, :enumeration_type, :first_name, :last_name, :organization_name, :address_purpose, :address_line, :city, :state, :postal_code, :country_code, :telephone_number, :fax_number])
  end
end

#cast -->  # Casts only the allowed fields from attrs into the struct
#validate --> # Ensures these fields must be present
