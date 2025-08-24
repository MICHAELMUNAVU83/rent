defmodule Rent.Apartments.Apartment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "apartments" do
    field :name, :string
    field :location, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(apartment, attrs) do
    apartment
    |> cast(attrs, [:name, :location])
    |> validate_required([:name, :location])
  end
end
