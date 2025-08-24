defmodule RentWeb.HouseLive.Index do
  use RentWeb, :system_live_view

  alias Rent.Properties
  alias Rent.Houses.House
  alias Rent.Houses

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Houses")
      |> assign(:page_subtitle, "Manage all houses and track payments")
      |> assign(:current_path, "/houses")
      |> stream(:houses, Houses.list_all_houses_with_apartments())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(:houses, Houses.list_all_houses_with_apartments())
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit House")
    |> assign(:house, Houses.get_house!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New House")
    |> assign(:house, %House{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Houses")
    |> assign(:house, nil)
  end

  @impl true
  def handle_info({RentWeb.HouseLive.FormComponent, {:saved, house}}, socket) do
    {:noreply, stream_insert(socket, :houses, house)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    house = Properties.get_house!(id)
    {:ok, _} = Properties.delete_house(house)

    {:noreply, stream_delete(socket, :houses, house)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <!-- Page Header -->
    <div class="mb-8">
      <div class="sm:flex sm:items-center sm:justify-between">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Houses</h1>
          <p class="mt-2 text-sm text-gray-700">
            Manage all houses across your apartment complexes and track tenant payments.
          </p>
        </div>
        <div class="mt-4 sm:ml-4 sm:mt-0">
          <.link patch={~p"/houses/new"}>
            <.button class="bg-blue-600 hover:bg-blue-700 text-white">
              <.icon name="hero-plus" class="w-4 h-4 mr-2" /> New House
            </.button>
          </.link>
        </div>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
      <.stat_card_small
        title="Total Houses"
        value={Enum.count(@streams.houses.inserts)}
        icon="hero-home"
        color="blue"
      />
      <.stat_card_small
        title="With Tenants"
        value={
          @streams.houses.inserts
          |> Enum.count(fn {_, _, house, _} -> house.tenant && house.tenant != "" end)
        }
        icon="hero-users"
        color="green"
      />
      <.stat_card_small
        title="Vacant"
        value={
          @streams.houses.inserts
          |> Enum.count(fn {_, _, house, _} -> !house.tenant || house.tenant == "" end)
        }
        icon="hero-key"
        color="orange"
      />
      <.stat_card_small title="Pending Payments" value="12" icon="hero-clock" color="purple" />
    </div>

    <!-- Houses Table -->
    <div class="bg-white shadow-sm ring-1 ring-gray-900/5 rounded-lg">
      <div class="px-6 py-4 border-b border-gray-200">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold text-gray-900">All Houses</h3>
          <div class="flex items-center space-x-3">
            <!-- Search -->
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <.icon name="hero-magnifying-glass" class="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="text"
                placeholder="Search houses..."
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
                House
              </th>
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
                Tenant
              </th>
              <th
                scope="col"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Payments
              </th>
              <th scope="col" class="relative px-6 py-3">
                <span class="sr-only">Actions</span>
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr
              :for={{id, house} <- @streams.houses}
              id={id}
              class="hover:bg-gray-50 cursor-pointer"
              phx-click={JS.navigate(~p"/houses/#{house}")}
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <div class="flex-shrink-0 h-10 w-10">
                    <div class="h-10 w-10 rounded-lg bg-green-100 flex items-center justify-center">
                      <.icon name="hero-home" class="h-6 w-6 text-green-600" />
                    </div>
                  </div>
                  <div class="ml-4">
                    <div class="text-sm font-medium text-gray-900">
                      {house.name}
                    </div>
                    <div class="text-sm text-gray-500">
                      House ID: #{house.id}
                    </div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm">
                  <div class="font-medium text-gray-900">
                    {house.apartment.name}
                  </div>
                  <div class="text-gray-500">
                    {house.apartment.location}
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div :if={house.tenant && house.tenant != ""} class="text-sm">
                  <div class="font-medium text-gray-900">{house.tenant}</div>
                  <div class="text-green-600 text-xs">Active tenant</div>
                </div>
                <div :if={!house.tenant || house.tenant == ""} class="text-sm">
                  <div class="text-gray-500">No tenant</div>
                  <div class="text-orange-600 text-xs">Vacant</div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm">
                  <div class="text-green-600">5 completed</div>
                  <div class="text-orange-600">2 pending</div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <div class="flex items-center justify-end space-x-2">
                  <.link
                    navigate={~p"/houses/#{house}"}
                    class="text-blue-600 hover:text-blue-900"
                    title="View Payments"
                  >
                    <.icon name="hero-banknotes" class="h-4 w-4" />
                  </.link>
                  <.link
                    patch={~p"/houses/#{house}/edit"}
                    class="text-gray-600 hover:text-gray-900"
                    title="Edit"
                  >
                    <.icon name="hero-pencil" class="h-4 w-4" />
                  </.link>
                  <.link
                    phx-click={JS.push("delete", value: %{id: house.id}) |> hide("##{id}")}
                    data-confirm="Are you sure you want to delete this house?"
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
      :if={Enum.empty?(@streams.houses.inserts)}
      class="bg-white shadow-sm ring-1 ring-gray-900/5 rounded-lg"
    >
      <div class="text-center py-12">
        <.icon name="hero-home" class="mx-auto h-12 w-12 text-gray-400" />
        <h3 class="mt-2 text-sm font-semibold text-gray-900">No houses</h3>
        <p class="mt-1 text-sm text-gray-500">
          Get started by creating your first house for payment tracking.
        </p>
        <div class="mt-6">
          <.link patch={~p"/houses/new"}>
            <.button class="bg-blue-600 hover:bg-blue-700 text-white">
              <.icon name="hero-plus" class="w-4 h-4 mr-2" /> New House
            </.button>
          </.link>
        </div>
      </div>
    </div>

    <!-- Modal for New/Edit -->
    <.modal
      :if={@live_action in [:new, :edit]}
      id="house-modal"
      show
      on_cancel={JS.patch(~p"/houses")}
    >
      <.live_component
        module={RentWeb.HouseLive.FormComponent}
        id={@house.id || :new}
        title={@page_title}
        action={@live_action}
        apartment={nil}
        house={@house}
        patch={~p"/houses"}
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
