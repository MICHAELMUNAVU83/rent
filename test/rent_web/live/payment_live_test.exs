defmodule RentWeb.PaymentLiveTest do
  use RentWeb.ConnCase

  import Phoenix.LiveViewTest
  import Rent.PaymentsFixtures

  @create_attrs %{month: "some month", customer_name: "some customer_name", customer_email: "some customer_email", customer_phone_number: "some customer_phone_number", is_complete: true}
  @update_attrs %{month: "some updated month", customer_name: "some updated customer_name", customer_email: "some updated customer_email", customer_phone_number: "some updated customer_phone_number", is_complete: false}
  @invalid_attrs %{month: nil, customer_name: nil, customer_email: nil, customer_phone_number: nil, is_complete: false}

  defp create_payment(_) do
    payment = payment_fixture()
    %{payment: payment}
  end

  describe "Index" do
    setup [:create_payment]

    test "lists all payments", %{conn: conn, payment: payment} do
      {:ok, _index_live, html} = live(conn, ~p"/payments")

      assert html =~ "Listing Payments"
      assert html =~ payment.month
    end

    test "saves new payment", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/payments")

      assert index_live |> element("a", "New Payment") |> render_click() =~
               "New Payment"

      assert_patch(index_live, ~p"/payments/new")

      assert index_live
             |> form("#payment-form", payment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#payment-form", payment: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/payments")

      html = render(index_live)
      assert html =~ "Payment created successfully"
      assert html =~ "some month"
    end

    test "updates payment in listing", %{conn: conn, payment: payment} do
      {:ok, index_live, _html} = live(conn, ~p"/payments")

      assert index_live |> element("#payments-#{payment.id} a", "Edit") |> render_click() =~
               "Edit Payment"

      assert_patch(index_live, ~p"/payments/#{payment}/edit")

      assert index_live
             |> form("#payment-form", payment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#payment-form", payment: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/payments")

      html = render(index_live)
      assert html =~ "Payment updated successfully"
      assert html =~ "some updated month"
    end

    test "deletes payment in listing", %{conn: conn, payment: payment} do
      {:ok, index_live, _html} = live(conn, ~p"/payments")

      assert index_live |> element("#payments-#{payment.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#payments-#{payment.id}")
    end
  end

  describe "Show" do
    setup [:create_payment]

    test "displays payment", %{conn: conn, payment: payment} do
      {:ok, _show_live, html} = live(conn, ~p"/payments/#{payment}")

      assert html =~ "Show Payment"
      assert html =~ payment.month
    end

    test "updates payment within modal", %{conn: conn, payment: payment} do
      {:ok, show_live, _html} = live(conn, ~p"/payments/#{payment}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Payment"

      assert_patch(show_live, ~p"/payments/#{payment}/show/edit")

      assert show_live
             |> form("#payment-form", payment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#payment-form", payment: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/payments/#{payment}")

      html = render(show_live)
      assert html =~ "Payment updated successfully"
      assert html =~ "some updated month"
    end
  end
end
