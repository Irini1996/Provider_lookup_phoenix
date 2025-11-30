defmodule ProviderLookup.Providers.Provider do
  use Ecto.Schema
  import Ecto.Changeset

schema "providers" do
  field :npi_number, :string
  field :enumeration_type, :string
  field :first_name, :string
  field :last_name, :string
  field :organization_name, :string

  # Mailing Address
  field :address_purpose, :string
  field :address_line, :string
  field :city, :string
  field :state, :string
  field :postal_code, :string

  field :country_code, :string
  field :telephone_number, :string
  field :fax_number, :string

  # ----------------------------------------
  # PRACTICE ADDRESS (ΤΑ ΠΕΔΙΑ ΠΟΥ ΛΕΙΠΟΥΝ)
  # ----------------------------------------
  field :practice_address_1, :string
  field :practice_address_2, :string
  field :practice_city, :string
  field :practice_state, :string
  field :practice_zip, :string
  field :practice_country, :string
  field :practice_phone, :string

  has_many :provider_taxonomies, ProviderLookup.Providers.ProviderTaxonomy
  has_many :taxonomies, through: [:provider_taxonomies, :taxonomy]

  timestamps(type: :utc_datetime)
end


  @doc false
  def changeset(provider, attrs) do
    provider
    |> cast(attrs, [
      :npi_number, :enumeration_type, :first_name, :last_name,
      :organization_name,
      :address_purpose, :address_line, :city, :state, :postal_code,
      :country_code, :telephone_number, :fax_number
    ])
  end
end
