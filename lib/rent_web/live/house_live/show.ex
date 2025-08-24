defmodule RentWeb.HouseLive.Show do
  use RentWeb, :system_live_view

  alias Rent.Properties
  alias Rent.Payments
  alias Rent.Houses
  alias Rent.Payments.Payment

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:current_path, "/houses")

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    house = Houses.get_house_with_apartment(id)

    socket =
      socket
      |> assign(:page_title, house.name)
      |> assign(:page_subtitle, "payments and tenant information")
      |> assign(:house, house)
      |> stream(:payments, Payments.list_payments_by_house(id))
      |> apply_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  defp apply_action(socket, :show, _params) do
    socket
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> assign(:page_title, "Edit House")
  end

  defp apply_action(socket, :new_payment, _params) do
    socket
    |> assign(:page_title, "New Payment")
    |> assign(:payment, %Payment{house_id: socket.assigns.house.id})
  end

  defp apply_action(socket, :edit_payment, %{"payment_id" => payment_id}) do
    socket
    |> assign(:page_title, "Edit Payment")
    |> assign(:payment, Payments.get_payment!(payment_id))
  end

  @impl true
  def handle_info({RentWeb.HouseLive.FormComponent, {:saved, house}}, socket) do
    {:noreply, assign(socket, :house, house)}
  end

  @impl true
  def handle_info({RentWeb.PaymentLive.FormComponent, {:saved, payment}}, socket) do
    {:noreply, stream_insert(socket, :payments, payment)}
  end

  @impl true
  def handle_event("delete_payment", %{"id" => id}, socket) do
    payment = Payments.get_payment!(id)
    {:ok, _} = Payments.delete_payment(payment)

    {:noreply, stream_delete(socket, :payments, payment)}
  end

  @impl true
  def handle_event("toggle_payment_status", %{"id" => id}, socket) do
    payment = Payments.get_payment!(id)

    {:ok, updated_payment} =
      Payments.update_payment(payment, %{is_complete: !payment.is_complete})

    {:noreply, stream_insert(socket, :payments, updated_payment)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <!-- Breadcrumb Navigation -->
    <div class="mb-8">
      <nav class="flex mb-4" aria-label="Breadcrumb">
        <ol class="flex items-center space-x-2 text-sm">
          <li>
            <.link navigate={~p"/houses"} class="text-gray-500 hover:text-gray-700">
              Houses
            </.link>
          </li>
          <li class="flex items-center">
            <.icon name="hero-chevron-right" class="h-4 w-4 text-gray-400 mx-2" />
            <span class="text-gray-900 font-medium">{@house.name}</span>
          </li>
        </ol>
      </nav>
      
    <!-- House Information Card -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-8">
        <div class="flex items-center justify-between">
          <div class="flex items-center">
            <div class="flex-shrink-0 h-16 w-16">
              <div class="h-16 w-16 rounded-lg bg-green-100 flex items-center justify-center">
                <.icon name="hero-home" class="h-8 w-8 text-green-600" />
              </div>
            </div>
            <div class="ml-6">
              <h1 class="text-2xl font-bold text-gray-900">{@house.name}</h1>
              <p class="mt-1 text-sm text-gray-600">
                <span class="font-medium">Apartment:</span> {@house.apartment.name} · {@house.apartment.location}
              </p>
              <div class="mt-2">
                <div
                  :if={@house.tenant && @house.tenant != ""}
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800"
                >
                  <.icon name="hero-user" class="w-3 h-3 mr-1" />
                  {@house.tenant}
                </div>
                <div
                  :if={!@house.tenant || @house.tenant == ""}
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-800"
                >
                  <.icon name="hero-key" class="w-3 h-3 mr-1" /> No Tenant
                </div>
              </div>
            </div>
          </div>
          <div class="flex items-center space-x-3">
            <.link patch={~p"/houses/#{@house}/show/edit"} phx-click={JS.push_focus()}>
              <button class="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                <.icon name="hero-pencil" class="h-4 w-4 mr-2" /> Edit House
              </button>
            </.link>
          </div>
        </div>
      </div>
    </div>

    <!-- Payment Statistics -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
      <.payment_stat_card
        title="Total Payments"
        value={Enum.count(@streams.payments)}
        icon="hero-banknotes"
        color="blue"
      />
      <.payment_stat_card
        title="Completed"
        value={
          @streams.payments.inserts |> Enum.count(fn {_, _, payment, _} -> payment.is_complete end)
        }
        icon="hero-check-circle"
        color="green"
      />
      <.payment_stat_card
        title="Pending"
        value={
          @streams.payments.inserts |> Enum.count(fn {_, _, payment, _} -> !payment.is_complete end)
        }
        icon="hero-clock"
        color="orange"
      />
      <.payment_stat_card
        title="Total Amount"
        value={"KES #{@streams.payments.inserts |> Enum.map(fn {_,_ ,p, _} -> p.amount || 0 end) |> Enum.sum() }"}
        icon="hero-currency-dollar"
        color="purple"
      />
    </div>

    <!-- Payments Section -->
    <div class="mb-8">
      <div class="sm:flex sm:items-center sm:justify-between mb-6">
        <div>
          <h2 class="text-lg font-semibold text-gray-900">Payment History</h2>
          <p class="mt-1 text-sm text-gray-600">
            Track all payments for this house.
          </p>
        </div>
        <div class="mt-4 sm:ml-4 sm:mt-0">
          <.link patch={~p"/houses/#{@house}/payments/new"}>
            <.button class="bg-blue-600 hover:bg-blue-700 text-white">
              <.icon name="hero-plus" class="w-4 h-4 mr-2" /> Add Payment
            </.button>
          </.link>
        </div>
      </div>
      
    <!-- Payments Table -->
      <div
        :if={not Enum.empty?(@streams.payments.inserts)}
        class="bg-white shadow-sm ring-1 ring-gray-900/5 rounded-lg overflow-hidden"
      >
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
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
                Customer
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
            <tr :for={{id, payment} <- @streams.payments} id={id} class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm font-medium text-gray-900">
                  {payment.month}
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm">
                  <div class="font-medium text-gray-900">{payment.customer_name}</div>
                  <div class="text-gray-500">{payment.customer_email}</div>
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
                  phx-click="toggle_payment_status"
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
                    patch={~p"/houses/#{@house}/payments/#{payment}/edit"}
                    class="text-blue-600 hover:text-blue-900"
                    title="Edit Payment"
                  >
                    <.icon name="hero-pencil" class="h-4 w-4" />
                  </.link>
                  <.link
                    phx-click={JS.push("delete_payment", value: %{id: payment.id}) |> hide("##{id}")}
                    data-confirm="Are you sure you want to delete this payment?"
                    class="text-red-600 hover:text-red-900"
                    title="Delete Payment"
                  >
                    <.icon name="hero-trash" class="h-4 w-4" />
                  </.link>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      
    <!-- Empty State -->
      <div
        :if={Enum.empty?(@streams.payments.inserts)}
        class="bg-white rounded-lg shadow-sm border border-gray-200"
      >
        <div class="text-center py-12">
          <.icon name="hero-banknotes" class="mx-auto h-12 w-12 text-gray-400" />
          <h3 class="mt-2 text-sm font-semibold text-gray-900">No payments recorded</h3>
          <p class="mt-1 text-sm text-gray-500">
            Start tracking payments for this house.
          </p>
          <div class="mt-6">
            <.link patch={~p"/houses/#{@house}/payments/new"}>
              <.button class="bg-blue-600 hover:bg-blue-700 text-white">
                <.icon name="hero-plus" class="w-4 h-4 mr-2" /> Add Payment
              </.button>
            </.link>
          </div>
        </div>
      </div>
    </div>

    <!-- Modals -->
    <.modal
      :if={@live_action == :edit}
      id="house-modal"
      show
      on_cancel={JS.patch(~p"/houses/#{@house}")}
    >
      <.live_component
        module={RentWeb.HouseLive.FormComponent}
        id={@house.id}
        title={@page_title}
        action={@live_action}
        house={@house}
        patch={~p"/houses/#{@house}"}
      />
    </.modal>

    <.modal
      :if={@live_action in [:new_payment, :edit_payment]}
      id="payment-modal"
      show
      on_cancel={JS.patch(~p"/houses/#{@house}")}
    >
      <.live_component
        module={RentWeb.PaymentLive.FormComponent}
        id={@payment.id || :new}
        title={@page_title}
        action={@live_action}
        payment={@payment}
        house={@house}
        patch={~p"/houses/#{@house}"}
      />
    </.modal>
    """
  end

  # Payment stat card component
  attr :title, :string, required: true
  attr :value, :any, required: true
  attr :icon, :string, required: true
  attr :color, :string, required: true

  defp payment_stat_card(assigns) do
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
