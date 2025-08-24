defmodule Rent.HousesTest do
  use Rent.DataCase

  alias Rent.Houses

  describe "houses" do
    alias Rent.Houses.House

    import Rent.HousesFixtures

    @invalid_attrs %{name: nil, tenant: nil}

    test "list_houses/0 returns all houses" do
      house = house_fixture()
      assert Houses.list_houses() == [house]
    end

    test "get_house!/1 returns the house with given id" do
      house = house_fixture()
      assert Houses.get_house!(house.id) == house
    end

    test "create_house/1 with valid data creates a house" do
      valid_attrs = %{name: "some name", tenant: "some tenant"}

      assert {:ok, %House{} = house} = Houses.create_house(valid_attrs)
      assert house.name == "some name"
      assert house.tenant == "some tenant"
    end

    test "create_house/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Houses.create_house(@invalid_attrs)
    end

    test "update_house/2 with valid data updates the house" do
      house = house_fixture()
      update_attrs = %{name: "some updated name", tenant: "some updated tenant"}

      assert {:ok, %House{} = house} = Houses.update_house(house, update_attrs)
      assert house.name == "some updated name"
      assert house.tenant == "some updated tenant"
    end

    test "update_house/2 with invalid data returns error changeset" do
      house = house_fixture()
      assert {:error, %Ecto.Changeset{}} = Houses.update_house(house, @invalid_attrs)
      assert house == Houses.get_house!(house.id)
    end

    test "delete_house/1 deletes the house" do
      house = house_fixture()
      assert {:ok, %House{}} = Houses.delete_house(house)
      assert_raise Ecto.NoResultsError, fn -> Houses.get_house!(house.id) end
    end

    test "change_house/1 returns a house changeset" do
      house = house_fixture()
      assert %Ecto.Changeset{} = Houses.change_house(house)
    end
  end
end
