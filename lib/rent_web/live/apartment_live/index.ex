defmodule RentWeb.ApartmentLive.Index do
  use RentWeb, :system_live_view

  alias Rent.Apartments
  alias Rent.Apartments.Apartment

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Apartments")
      |> assign(:page_subtitle, "Manage your apartment units")
      |> assign(:current_path, "/apartments")
      |> stream(:apartments, Apartments.list_apartments())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> stream(:apartments, Apartments.list_apartments())
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Apartment")
    |> assign(:apartment, Apartments.get_apartment!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Apartment")
    |> assign(:apartment, %Apartment{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Apartments")
    |> assign(:apartment, nil)
  end

  @impl true
  def handle_info({RentManagerWeb.ApartmentLive.FormComponent, {:saved, apartment}}, socket) do
    {:noreply, stream_insert(socket, :apartments, apartment)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    apartment = Apartments.get_apartment!(id)
    {:ok, _} = Apartments.delete_apartment(apartment)

    {:noreply, stream_delete(socket, :apartments, apartment)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <!-- Page Header -->
    <div class="mb-8">
      <div class="sm:flex sm:items-center sm:justify-between">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Apartments</h1>
          <p class="mt-2 text-sm text-gray-700">
            Manage your apartment units, track occupancy, and monitor rental income.
          </p>
        </div>
        <div class="mt-4 sm:ml-4 sm:mt-0">
          <.link patch={~p"/apartments/new"}>
            <.button class="bg-blue-600 hover:bg-blue-700 text-white">
              <.icon name="hero-plus" class="w-4 h-4 mr-2" /> New Apartment
            </.button>
          </.link>
        </div>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
      <.stat_card_small
        title="Total Apartments"
        value={length(@streams.apartments.inserts)}
        icon="hero-building-office"
        color="blue"
      />
      <.stat_card_small title="Recently Added" value="2" icon="hero-plus-circle" color="green" />
      <.stat_card_small title="This Month" value="5" icon="hero-calendar-days" color="purple" />
    </div>

    <!-- Apartments Table -->
    <div class="bg-white shadow-sm ring-1 ring-gray-900/5 rounded-lg">
      <div class="px-6 py-4 border-b border-gray-200">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold text-gray-900">All Apartments</h3>
          <div class="flex items-center space-x-3">
            <!-- Search -->
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <.icon name="hero-magnifying-glass" class="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="text"
                placeholder="Search apartments..."
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
                Apartment
              </th>
              <th
                scope="col"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Created
              </th>
              <th scope="col" class="relative px-6 py-3">
                <span class="sr-only">Actions</span>
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr
              :for={{id, apartment} <- @streams.apartments}
              id={id}
              class="hover:bg-gray-50 cursor-pointer"
              phx-click={JS.navigate(~p"/apartments/#{apartment}")}
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <div class="flex-shrink-0 h-10 w-10">
                    <div class="h-10 w-10 rounded-lg bg-blue-100 flex items-center justify-center">
                      <.icon name="hero-building-office" class="h-6 w-6 text-blue-600" />
                    </div>
                  </div>
                  <div class="ml-4">
                    <div class="text-sm font-medium text-gray-900">
                      {apartment.name}
                    </div>
                    <div class="text-sm text-gray-500">
                      {apartment.location}
                    </div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {apartment.inserted_at |> Calendar.strftime("%b %d, %Y")}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <div class="flex items-center justify-end space-x-2">
                  <.link
                    navigate={~p"/apartments/#{apartment}"}
                    class="text-gray-600 hover:text-gray-900"
                    title="View Details"
                  >
                    <.icon name="hero-eye" class="h-4 w-4" />
                  </.link>
                  <.link
                    patch={~p"/apartments/#{apartment}/edit"}
                    class="text-blue-600 hover:text-blue-900"
                    title="Edit"
                  >
                    <.icon name="hero-pencil" class="h-4 w-4" />
                  </.link>
                  <.link
                    phx-click={JS.push("delete", value: %{id: apartment.id}) |> hide("##{id}")}
                    data-confirm="Are you sure you want to delete this apartment?"
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

    <!-- Empty State (show when no apartments) -->
    <div
      :if={Enum.empty?(@streams.apartments.inserts)}
      class="bg-white shadow-sm ring-1 ring-gray-900/5 rounded-lg"
    >
      <div class="text-center py-12">
        <.icon name="hero-building-office" class="mx-auto h-12 w-12 text-gray-400" />
        <h3 class="mt-2 text-sm font-semibold text-gray-900">No apartments</h3>
        <p class="mt-1 text-sm text-gray-500">Get started by creating your first apartment unit.</p>
        <div class="mt-6">
          <.link patch={~p"/apartments/new"}>
            <.button class="bg-blue-600 hover:bg-blue-700 text-white">
              <.icon name="hero-plus" class="w-4 h-4 mr-2" /> New Apartment
            </.button>
          </.link>
        </div>
      </div>
    </div>

    <!-- Modal for New/Edit -->
    <.modal
      :if={@live_action in [:new, :edit]}
      id="apartment-modal"
      show
      on_cancel={JS.patch(~p"/apartments")}
    >
      <.live_component
        module={RentWeb.ApartmentLive.FormComponent}
        id={@apartment.id || :new}
        title={@page_title}
        action={@live_action}
        apartment={@apartment}
        patch={~p"/apartments"}
      />
    </.modal>
    """
  end

  # Small stat card component
  attr :title, :string, required: true
  attr :value, :string, required: true
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

  # Status badge component
  attr :status, :string, required: true

  defp status_badge(assigns) do
    ~H"""
    <span class={[
      "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
      case @status do
        "occupied" -> "bg-green-100 text-green-800"
        "vacant" -> "bg-orange-100 text-orange-800"
        "maintenance" -> "bg-red-100 text-red-800"
        _ -> "bg-gray-100 text-gray-800"
      end
    ]}>
      <div class={[
        "w-1.5 h-1.5 rounded-full mr-1.5",
        case @status do
          "occupied" -> "bg-green-400"
          "vacant" -> "bg-orange-400"
          "maintenance" -> "bg-red-400"
          _ -> "bg-gray-400"
        end
      ]}>
      </div>
      {String.capitalize(@status)}
    </span>
    """
  end
end
