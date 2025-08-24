defmodule Rent.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :customer_name, :string
      add :customer_email, :string
      add :customer_phone_number, :string
      add :month, :string
      add :is_complete, :boolean, default: false, null: false
      add :house_id, references(:houses, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:payments, [:house_id])
  end
end
