defmodule Rent.Houses do
  @moduledoc """
  The Houses context.
  """

  import Ecto.Query, warn: false
  alias Rent.Repo

  alias Rent.Houses.House

  @doc """
  Returns the list of houses.

  ## Examples

      iex> list_houses()
      [%House{}, ...]

  """
  def list_houses do
    Repo.all(House)
  end

  def list_all_houses_with_apartments do
    Repo.all(from h in House, where: not is_nil(h.apartment_id), preload: [:apartment])
  end

  def list_houses_by_apartment(apartment_id) do
    House
    |> where([h], h.apartment_id == ^apartment_id)
    |> Repo.all()
  end

  @doc """
  Gets a single house.

  Raises `Ecto.NoResultsError` if the House does not exist.

  ## Examples

      iex> get_house!(123)
      %House{}

      iex> get_house!(456)
      ** (Ecto.NoResultsError)

  """
  def get_house!(id), do: Repo.get!(House, id)

  @doc """
  Creates a house.

  ## Examples

      iex> create_house(%{field: value})
      {:ok, %House{}}

      iex> create_house(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_house(attrs \\ %{}) do
    %House{}
    |> House.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a house.

  ## Examples

      iex> update_house(house, %{field: new_value})
      {:ok, %House{}}

      iex> update_house(house, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_house(%House{} = house, attrs) do
    house
    |> House.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a house.

  ## Examples

      iex> delete_house(house)
      {:ok, %House{}}

      iex> delete_house(house)
      {:error, %Ecto.Changeset{}}

  """
  def delete_house(%House{} = house) do
    Repo.delete(house)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking house changes.

  ## Examples

      iex> change_house(house)
      %Ecto.Changeset{data: %House{}}

  """
  def change_house(%House{} = house, attrs \\ %{}) do
    House.changeset(house, attrs)
  end
end
