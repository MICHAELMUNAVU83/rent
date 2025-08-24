defmodule Rent.ApartmentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Rent.Apartments` context.
  """

  @doc """
  Generate a apartment.
  """
  def apartment_fixture(attrs \\ %{}) do
    {:ok, apartment} =
      attrs
      |> Enum.into(%{
        location: "some location",
        name: "some name"
      })
      |> Rent.Apartments.create_apartment()

    apartment
  end
end
