defmodule Rent.PaymentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Rent.Payments` context.
  """

  @doc """
  Generate a payment.
  """
  def payment_fixture(attrs \\ %{}) do
    {:ok, payment} =
      attrs
      |> Enum.into(%{
        customer_email: "some customer_email",
        customer_name: "some customer_name",
        customer_phone_number: "some customer_phone_number",
        is_complete: true,
        month: "some month"
      })
      |> Rent.Payments.create_payment()

    payment
  end
end
