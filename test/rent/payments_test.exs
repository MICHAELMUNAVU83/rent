defmodule Rent.PaymentsTest do
  use Rent.DataCase

  alias Rent.Payments

  describe "payments" do
    alias Rent.Payments.Payment

    import Rent.PaymentsFixtures

    @invalid_attrs %{month: nil, customer_name: nil, customer_email: nil, customer_phone_number: nil, is_complete: nil}

    test "list_payments/0 returns all payments" do
      payment = payment_fixture()
      assert Payments.list_payments() == [payment]
    end

    test "get_payment!/1 returns the payment with given id" do
      payment = payment_fixture()
      assert Payments.get_payment!(payment.id) == payment
    end

    test "create_payment/1 with valid data creates a payment" do
      valid_attrs = %{month: "some month", customer_name: "some customer_name", customer_email: "some customer_email", customer_phone_number: "some customer_phone_number", is_complete: true}

      assert {:ok, %Payment{} = payment} = Payments.create_payment(valid_attrs)
      assert payment.month == "some month"
      assert payment.customer_name == "some customer_name"
      assert payment.customer_email == "some customer_email"
      assert payment.customer_phone_number == "some customer_phone_number"
      assert payment.is_complete == true
    end

    test "create_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_payment(@invalid_attrs)
    end

    test "update_payment/2 with valid data updates the payment" do
      payment = payment_fixture()
      update_attrs = %{month: "some updated month", customer_name: "some updated customer_name", customer_email: "some updated customer_email", customer_phone_number: "some updated customer_phone_number", is_complete: false}

      assert {:ok, %Payment{} = payment} = Payments.update_payment(payment, update_attrs)
      assert payment.month == "some updated month"
      assert payment.customer_name == "some updated customer_name"
      assert payment.customer_email == "some updated customer_email"
      assert payment.customer_phone_number == "some updated customer_phone_number"
      assert payment.is_complete == false
    end

    test "update_payment/2 with invalid data returns error changeset" do
      payment = payment_fixture()
      assert {:error, %Ecto.Changeset{}} = Payments.update_payment(payment, @invalid_attrs)
      assert payment == Payments.get_payment!(payment.id)
    end

    test "delete_payment/1 deletes the payment" do
      payment = payment_fixture()
      assert {:ok, %Payment{}} = Payments.delete_payment(payment)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_payment!(payment.id) end
    end

    test "change_payment/1 returns a payment changeset" do
      payment = payment_fixture()
      assert %Ecto.Changeset{} = Payments.change_payment(payment)
    end
  end
end
