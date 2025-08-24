defmodule Rent.Repo.Migrations.AddAmount do
  use Ecto.Migration

  def change do
    alter table(:payments) do
      add :amount, :integer
    end
  end
end
