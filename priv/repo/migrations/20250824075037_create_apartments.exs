defmodule Rent.Repo.Migrations.CreateApartments do
  use Ecto.Migration

  def change do
    create table(:apartments) do
      add :name, :string
      add :location, :string
      add :user_id , references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
