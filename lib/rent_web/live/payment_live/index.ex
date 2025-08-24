defmodule RentWeb.PaymentLive.Index do
  use RentWeb, :system_live_view

  alias Rent.Payments
  alias Rent.Payments.Payment
  alias Rent.Properties

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Payments")
      |> assign(:page_subtitle, "Track all rent payments across your properties")
      |> assign(:current_path, "/payments")
      |> stream(:payments, Payments.list_payments_with_house_and_apartment())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Payment")
    |> assign(:payment, Payments.get_payment!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Payment")
    |> assign(:payment, %Payment{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Payments")
    |> assign(:payment, nil)
  end

  @impl true
  def handle_info({RentWeb.PaymentLive.FormComponent, {:saved, payment}}, socket) do
    {:noreply, stream_insert(socket, :payments, payment)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    payment = Payments.get_payment!(id)
    {:ok, _} = Payments.delete_payment(payment)

    {:noreply, stream_delete(socket, :payments, payment)}
  end

  @impl true
  def handle_event("toggle_status", %{"id" => id}, socket) do
    payment = Payments.get_payment!(id)

    {:ok, updated_payment} =
      Payments.update_payment(payment, %{is_complete: !payment.is_complete})

    {:noreply, stream_insert(socket, :payments, updated_payment)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <!-- Page Header -->
    <div class="mb-8">
      <div class="sm:flex sm:items-center sm:justify-between">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Payments</h1>
          <p class="mt-2 text-sm text-gray-700">
            Track and manage all rent payments across your property portfolio.
          </p>
        </div>
        <div class="mt-4 sm:ml-4 sm:mt-0">
          <.link patch={~p"/payments/new"}>
            <.button class="bg-blue-600 hover:bg-blue-700 text-white">
              <.icon name="hero-plus" class="w-4 h-4 mr-2" /> New Payment
            </.button>
          </.link>
        </div>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
      <.stat_card_small
        title="Total Payments"
        value={Enum.count(@streams.payments)}
        icon="hero-banknotes"
        color="blue"
      />
      <.stat_card_small
        title="Completed"
        value={
          @streams.payments.inserts |> Enum.count(fn {_, _, payment, _} -> payment.is_complete end)
        }
        icon="hero-check-circle"
        color="green"
      />
      <.stat_card_small
        title="Pending"
        value={
          @streams.payments.inserts |> Enum.count(fn {_, _, payment, _} -> !payment.is_complete end)
        }
        icon="hero-clock"
        color="orange"
      />
      <.stat_card_small
        title="Total Revenue"
        value={"KES #{@streams.payments.inserts |> Enum.filter(fn {_,_, p, _} -> p.is_complete end) |> Enum.map(fn {_,_, p, _} -> p.amount || 0 end) |> Enum.sum() }"}
        icon="hero-currency-dollar"
        color="purple"
      />
    </div>

    <!-- Payments Table -->
    <div class="bg-white shadow-sm ring-1 ring-gray-900/5 rounded-lg">
      <div class="px-6 py-4 border-b border-gray-200">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold text-gray-900">All Payments</h3>
          <div class="flex items-center space-x-3">
            <!-- Search -->
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <.icon name="hero-magnifying-glass" class="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="text"
                placeholder="Search payments..."
                class="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
              />
            </div>
            <!-- Filter -->
            <button class="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
              <.icon name="hero-funnel" class="h-4 w-4 mr-2" /> Filter
            </button>
          </div>
        </div>
      </div>

      <div class="overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th
                scope="col"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Customer
              </th>
              <th
                scope="col"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Property
              </th>
              <th
                scope="col"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Month
              </th>
              <th
                scope="col"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Amount
              </th>
              <th
                scope="col"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Status
              </th>
              <th
                scope="col"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Date
              </th>
              <th scope="col" class="relative px-6 py-3">
                <span class="sr-only">Actions</span>
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr
              :for={{id, payment} <- @streams.payments}
              id={id}
              class="hover:bg-gray-50 cursor-pointer"
              phx-click={JS.navigate(~p"/payments/#{payment}")}
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <div class="flex-shrink-0 h-10 w-10">
                    <div class="h-10 w-10 rounded-full bg-blue-100 flex items-center justify-center">
                      <.icon name="hero-user" class="h-6 w-6 text-blue-600" />
                    </div>
                  </div>
                  <div class="ml-4">
                    <div class="text-sm font-medium text-gray-900">
                      {payment.customer_name}
                    </div>
                    <div class="text-sm text-gray-500">
                      {payment.customer_email}
                    </div>
                    <div :if={payment.customer_phone_number} class="text-xs text-gray-400">
                      {payment.customer_phone_number}
                    </div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm">
                  <div class="font-medium text-gray-900">
                    {payment.house.name}
                  </div>
                  <div class="text-gray-500">
                    {payment.house.apartment.name}
                  </div>
                  <div class="text-xs text-gray-400">
                    {payment.house.apartment.location}
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm font-medium text-gray-900">
                  {payment.month}
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm font-medium text-gray-900">
                  KES{if payment.amount,
                    do: :erlang.float_to_binary(payment.amount / 100, decimals: 2),
                    else: "0.00"}
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <button
                  phx-click="toggle_status"
                  phx-value-id={payment.id}
                  class={[
                    "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium cursor-pointer",
                    if(payment.is_complete,
                      do: "bg-green-100 text-green-800 hover:bg-green-200",
                      else: "bg-orange-100 text-orange-800 hover:bg-orange-200"
                    )
                  ]}
                >
                  <div class={[
                    "w-1.5 h-1.5 rounded-full mr-1.5",
                    if(payment.is_complete, do: "bg-green-400", else: "bg-orange-400")
                  ]}>
                  </div>
                  {if payment.is_complete, do: "Completed", else: "Pending"}
                </button>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {payment.inserted_at |> Calendar.strftime("%b %d, %Y")}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <div class="flex items-center justify-end space-x-2">
                  <.link
                    navigate={~p"/payments/#{payment}"}
                    class="text-blue-600 hover:text-blue-900"
                    title="View Details"
                  >
                    <.icon name="hero-eye" class="h-4 w-4" />
                  </.link>
                  <.link
                    patch={~p"/payments/#{payment}/edit"}
                    class="text-gray-600 hover:text-gray-900"
                    title="Edit"
                  >
                    <.icon name="hero-pencil" class="h-4 w-4" />
                  </.link>
                  <.link
                    phx-click={JS.push("delete", value: %{id: payment.id}) |> hide("##{id}")}
                    data-confirm="Are you sure you want to delete this payment?"
                    class="text-red-600 hover:text-red-900"
                    title="Delete"
                  >
                    <.icon name="hero-trash" class="h-4 w-4" />
                  </.link>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Empty State -->
    <div
      :if={Enum.empty?(@streams.payments.inserts)}
      class="bg-white shadow-sm ring-1 ring-gray-900/5 rounded-lg"
    >
      <div class="text-center py-12">
        <.icon name="hero-banknotes" class="mx-auto h-12 w-12 text-gray-400" />
        <h3 class="mt-2 text-sm font-semibold text-gray-900">No payments recorded</h3>
        <p class="mt-1 text-sm text-gray-500">Get started by recording your first payment.</p>
        <div class="mt-6">
          <.link patch={~p"/payments/new"}>
            <.button class="bg-blue-600 hover:bg-blue-700 text-white">
              <.icon name="hero-plus" class="w-4 h-4 mr-2" /> New Payment
            </.button>
          </.link>
        </div>
      </div>
    </div>

    <!-- Modal for New/Edit -->
    <.modal
      :if={@live_action in [:new, :edit]}
      id="payment-modal"
      show
      on_cancel={JS.patch(~p"/payments")}
    >
      <.live_component
        module={RentWeb.PaymentLive.GlobalFormComponent}
        id={@payment.id || :new}
        title={@page_title}
        action={@live_action}
        payment={@payment}
        patch={~p"/payments"}
      />
    </.modal>
    """
  end

  # Small stat card component
  attr :title, :string, required: true
  attr :value, :any, required: true
  attr :icon, :string, required: true
  attr :color, :string, required: true

  defp stat_card_small(assigns) do
    ~H"""
    <div class="bg-white overflow-hidden shadow-sm ring-1 ring-gray-900/5 rounded-lg">
      <div class="p-5">
        <div class="flex items-center">
          <div class="flex-shrink-0">
            <div class={[
              "p-2 rounded-md",
              case @color do
                "blue" -> "bg-blue-100"
                "green" -> "bg-green-100"
                "orange" -> "bg-orange-100"
                "purple" -> "bg-purple-100"
              end
            ]}>
              <.icon
                name={@icon}
                class={[
                  "h-5 w-5",
                  case @color do
                    "blue" -> "text-blue-600"
                    "green" -> "text-green-600"
                    "orange" -> "text-orange-600"
                    "purple" -> "text-purple-600"
                  end
                ]}
              />
            </div>
          </div>
          <div class="ml-5 w-0 flex-1">
            <dl>
              <dt class="text-sm font-medium text-gray-500 truncate">{@title}</dt>
              <dd class="text-lg font-semibold text-gray-900">{@value}</dd>
            </dl>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
