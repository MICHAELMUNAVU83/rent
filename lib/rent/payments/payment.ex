defmodule Rent.Payments.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field :month, :string
    field :customer_name, :string
    field :customer_email, :string
    field :customer_phone_number, :string
    field :amount, :integer
    field :is_complete, :boolean, default: false
    belongs_to :house, Rent.Houses.House

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [
      :customer_name,
      :customer_email,
      :customer_phone_number,
      :month,
      :is_complete,
      :amount,
      :house_id
    ])
    |> validate_required([
      :customer_name,
      :customer_email,
      :customer_phone_number,
      :month,
      :is_complete
    ])
  end
end
