defmodule Rent.HousesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Rent.Houses` context.
  """

  @doc """
  Generate a house.
  """
  def house_fixture(attrs \\ %{}) do
    {:ok, house} =
      attrs
      |> Enum.into(%{
        name: "some name",
        tenant: "some tenant"
      })
      |> Rent.Houses.create_house()

    house
  end
end
