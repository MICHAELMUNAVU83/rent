defmodule Rent.ApartmentsTest do
  use Rent.DataCase

  alias Rent.Apartments

  describe "apartments" do
    alias Rent.Apartments.Apartment

    import Rent.ApartmentsFixtures

    @invalid_attrs %{name: nil, location: nil}

    test "list_apartments/0 returns all apartments" do
      apartment = apartment_fixture()
      assert Apartments.list_apartments() == [apartment]
    end

    test "get_apartment!/1 returns the apartment with given id" do
      apartment = apartment_fixture()
      assert Apartments.get_apartment!(apartment.id) == apartment
    end

    test "create_apartment/1 with valid data creates a apartment" do
      valid_attrs = %{name: "some name", location: "some location"}

      assert {:ok, %Apartment{} = apartment} = Apartments.create_apartment(valid_attrs)
      assert apartment.name == "some name"
      assert apartment.location == "some location"
    end

    test "create_apartment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Apartments.create_apartment(@invalid_attrs)
    end

    test "update_apartment/2 with valid data updates the apartment" do
      apartment = apartment_fixture()
      update_attrs = %{name: "some updated name", location: "some updated location"}

      assert {:ok, %Apartment{} = apartment} = Apartments.update_apartment(apartment, update_attrs)
      assert apartment.name == "some updated name"
      assert apartment.location == "some updated location"
    end

    test "update_apartment/2 with invalid data returns error changeset" do
      apartment = apartment_fixture()
      assert {:error, %Ecto.Changeset{}} = Apartments.update_apartment(apartment, @invalid_attrs)
      assert apartment == Apartments.get_apartment!(apartment.id)
    end

    test "delete_apartment/1 deletes the apartment" do
      apartment = apartment_fixture()
      assert {:ok, %Apartment{}} = Apartments.delete_apartment(apartment)
      assert_raise Ecto.NoResultsError, fn -> Apartments.get_apartment!(apartment.id) end
    end

    test "change_apartment/1 returns a apartment changeset" do
      apartment = apartment_fixture()
      assert %Ecto.Changeset{} = Apartments.change_apartment(apartment)
    end
  end
end
