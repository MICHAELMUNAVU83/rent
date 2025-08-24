defmodule Rent.Houses.House do
  use Ecto.Schema
  import Ecto.Changeset

  schema "houses" do
    field :name, :string
    field :tenant, :string
    field :rent_amount, :integer
    belongs_to :apartment, Rent.Apartments.Apartment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(house, attrs) do
    house
    |> cast(attrs, [:tenant, :name, :apartment_id, :rent_amount])
    |> validate_required([:tenant, :name, :apartment_id, :rent_amount])
  end
end
