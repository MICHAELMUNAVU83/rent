defmodule Rent.Repo.Migrations.CreateHouses do
  use Ecto.Migration

  def change do
    create table(:houses) do
      add :tenant, :string
      add :name, :string
      add :apartment_id, references(:apartments, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
