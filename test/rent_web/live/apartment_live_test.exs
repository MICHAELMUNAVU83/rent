defmodule RentWeb.ApartmentLiveTest do
  use RentWeb.ConnCase

  import Phoenix.LiveViewTest
  import Rent.ApartmentsFixtures

  @create_attrs %{name: "some name", location: "some location"}
  @update_attrs %{name: "some updated name", location: "some updated location"}
  @invalid_attrs %{name: nil, location: nil}

  defp create_apartment(_) do
    apartment = apartment_fixture()
    %{apartment: apartment}
  end

  describe "Index" do
    setup [:create_apartment]

    test "lists all apartments", %{conn: conn, apartment: apartment} do
      {:ok, _index_live, html} = live(conn, ~p"/apartments")

      assert html =~ "Listing Apartments"
      assert html =~ apartment.name
    end

    test "saves new apartment", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/apartments")

      assert index_live |> element("a", "New Apartment") |> render_click() =~
               "New Apartment"

      assert_patch(index_live, ~p"/apartments/new")

      assert index_live
             |> form("#apartment-form", apartment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#apartment-form", apartment: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/apartments")

      html = render(index_live)
      assert html =~ "Apartment created successfully"
      assert html =~ "some name"
    end

    test "updates apartment in listing", %{conn: conn, apartment: apartment} do
      {:ok, index_live, _html} = live(conn, ~p"/apartments")

      assert index_live |> element("#apartments-#{apartment.id} a", "Edit") |> render_click() =~
               "Edit Apartment"

      assert_patch(index_live, ~p"/apartments/#{apartment}/edit")

      assert index_live
             |> form("#apartment-form", apartment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#apartment-form", apartment: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/apartments")

      html = render(index_live)
      assert html =~ "Apartment updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes apartment in listing", %{conn: conn, apartment: apartment} do
      {:ok, index_live, _html} = live(conn, ~p"/apartments")

      assert index_live |> element("#apartments-#{apartment.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#apartments-#{apartment.id}")
    end
  end

  describe "Show" do
    setup [:create_apartment]

    test "displays apartment", %{conn: conn, apartment: apartment} do
      {:ok, _show_live, html} = live(conn, ~p"/apartments/#{apartment}")

      assert html =~ "Show Apartment"
      assert html =~ apartment.name
    end

    test "updates apartment within modal", %{conn: conn, apartment: apartment} do
      {:ok, show_live, _html} = live(conn, ~p"/apartments/#{apartment}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Apartment"

      assert_patch(show_live, ~p"/apartments/#{apartment}/show/edit")

      assert show_live
             |> form("#apartment-form", apartment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#apartment-form", apartment: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/apartments/#{apartment}")

      html = render(show_live)
      assert html =~ "Apartment updated successfully"
      assert html =~ "some updated name"
    end
  end
end
