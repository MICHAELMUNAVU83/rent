defmodule Rent.Repo.Migrations.AddRentAmount do
  use Ecto.Migration

  def change do
    alter table(:houses) do
      add :rent_amount, :integer
    end
  end
end
