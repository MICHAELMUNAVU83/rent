defmodule RentWeb.ApartmentLive.Show do
  use RentWeb, :system_live_view

  alias Rent.Apartments
  alias Rent.Houses
  alias Rent.Houses.House

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:current_path, "/apartments")

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    apartment = Apartments.get_apartment!(id)

    socket =
      socket
      |> assign(:page_title, apartment.name)
      |> assign(:page_subtitle, "Manage houses in this apartment complex")
      |> assign(:apartment, apartment)
      |> stream(:houses, Houses.list_houses_by_apartment(id))
      |> apply_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  defp apply_action(socket, :show, _params) do
    socket
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> assign(:page_title, "Edit Apartment")
  end

  defp apply_action(socket, :new_house, _params) do
    socket
    |> assign(:page_title, "Add New House")
    |> assign(:house, %House{apartment_id: socket.assigns.apartment.id})
  end

  defp apply_action(socket, :edit_house, %{"house_id" => house_id}) do
    socket
    |> assign(:page_title, "Edit House")
    |> assign(:house, Houses.get_house!(house_id))
  end

  @impl true
  def handle_info({RentManagerWeb.ApartmentLive.FormComponent, {:saved, apartment}}, socket) do
    {:noreply, assign(socket, :apartment, apartment)}
  end

  @impl true
  def handle_info({RentManagerWeb.HouseLive.FormComponent, {:saved, house}}, socket) do
    {:noreply, stream_insert(socket, :houses, house)}
  end

  @impl true
  def handle_event("delete_house", %{"id" => id}, socket) do
    house = Apartments.get_house!(id)
    {:ok, _} = Apartments.delete_house(house)

    {:noreply, stream_delete(socket, :houses, house)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <!-- Apartment Header -->
    <div class="mb-8">
      <nav class="flex mb-4" aria-label="Breadcrumb">
        <ol class="flex items-center space-x-2 text-sm">
          <li>
            <.link navigate={~p"/apartments"} class="text-gray-500 hover:text-gray-700">
              Apartments
            </.link>
          </li>
          <li class="flex items-center">
            <.icon name="hero-chevron-right" class="h-4 w-4 text-gray-400 mx-2" />
            <span class="text-gray-900 font-medium">{@apartment.name}</span>
          </li>
        </ol>
      </nav>

      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-8">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">{@apartment.name}</h1>
            <p class="mt-1 text-sm text-gray-600">{@apartment.location}</p>
          </div>
          <div class="flex items-center space-x-3">
            <.link patch={~p"/apartments/#{@apartment}/show/edit"} phx-click={JS.push_focus()}>
              <button class="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                <.icon name="hero-pencil" class="h-4 w-4 mr-2" /> Edit Apartment
              </button>
            </.link>
          </div>
        </div>
      </div>
    </div>

    <!-- Houses Section -->
    <div class="mb-8">
      <div class="sm:flex sm:items-center sm:justify-between mb-6">
        <div>
          <h2 class="text-lg font-semibold text-gray-900">Houses</h2>
          <p class="mt-1 text-sm text-gray-600">
            Manage individual houses within this apartment complex.
          </p>
        </div>
        <div class="mt-4 sm:ml-4 sm:mt-0">
          <.link patch={~p"/apartments/#{@apartment}/houses/new"}>
            <.button class="bg-blue-600 hover:bg-blue-700 text-white">
              <.icon name="hero-plus" class="w-4 h-4 mr-2" /> Add House
            </.button>
          </.link>
        </div>
      </div>
      
    <!-- Houses Grid -->
      <div
        :if={not Enum.empty?(@streams.houses.inserts)}
        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
      >
        <div
          :for={{id, house} <- @streams.houses}
          id={id}
          class="bg-white rounded-lg shadow-sm border border-gray-200 hover:shadow-md transition-shadow duration-200"
        >
          <div class="p-6">
            <div class="flex items-start justify-between">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <div class="h-12 w-12 rounded-lg bg-green-100 flex items-center justify-center">
                    <.icon name="hero-home" class="h-6 w-6 text-green-600" />
                  </div>
                </div>
                <div class="ml-4">
                  <h3 class="text-lg font-medium text-gray-900">
                    {house.name || "House #{house.unit_number}"}
                  </h3>
                </div>
              </div>
              
    <!-- Actions Dropdown -->
              <div class="flex items-center space-x-2">
                <.link
                  patch={~p"/apartments/#{@apartment}/houses/#{house}/edit"}
                  class="text-gray-400 hover:text-gray-600"
                  title="Edit House"
                >
                  <.icon name="hero-pencil" class="h-4 w-4" />
                </.link>
                <.link
                  phx-click={JS.push("delete_house", value: %{id: house.id}) |> hide("##{id}")}
                  data-confirm="Are you sure you want to delete this house?"
                  class="text-red-400 hover:text-red-600"
                  title="Delete House"
                >
                  <.icon name="hero-trash" class="h-4 w-4" />
                </.link>
              </div>
            </div>
            
    <!-- House Details -->
            <div class="mt-4 space-y-3">
              <!-- Tenant Info -->
              <div :if={house.tenant} class="flex items-center text-sm">
                <.icon name="hero-user" class="h-4 w-4 text-gray-400 mr-2" />
                <span class="text-gray-900">{house.tenant}</span>
              </div>
              <div :if={!house.tenant} class="flex items-center text-sm">
                <.icon name="hero-user" class="h-4 w-4 text-gray-400 mr-2" />
                <span class="text-gray-500">No tenant assigned</span>
              </div>
              
    <!-- Rent -->
              <div :if={house.rent_amount} class="flex items-center text-sm">
                <.icon name="hero-banknotes" class="h-4 w-4 text-gray-400 mr-2" />
                <span class="text-gray-900">KES {house.rent_amount}/month</span>
              </div>
              
    <!-- Status -->
              <div class="flex items-center text-sm">
                <.house_status_badge status={house.tenant == nil} />
              </div>
            </div>
            
    <!-- Action Button -->
            <div class="mt-4 pt-4 border-t border-gray-200">
              <.link
                navigate={~p"/houses/#{house}"}
                class="text-sm text-blue-600 hover:text-blue-800 font-medium"
              >
                View Details →
              </.link>
            </div>
          </div>
        </div>
      </div>
      
    <!-- Empty State -->
      <div
        :if={Enum.empty?(@streams.houses.inserts)}
        class="bg-white rounded-lg shadow-sm border border-gray-200"
      >
        <div class="text-center py-12">
          <.icon name="hero-home" class="mx-auto h-12 w-12 text-gray-400" />
          <h3 class="mt-2 text-sm font-semibold text-gray-900">No houses</h3>
          <p class="mt-1 text-sm text-gray-500">
            Get started by adding the first house to this apartment complex.
          </p>
          <div class="mt-6">
            <.link patch={~p"/apartments/#{@apartment}/houses/new"}>
              <.button class="bg-blue-600 hover:bg-blue-700 text-white">
                <.icon name="hero-plus" class="w-4 h-4 mr-2" /> Add House
              </.button>
            </.link>
          </div>
        </div>
      </div>
    </div>

    <!-- Modals -->
    <.modal
      :if={@live_action == :edit}
      id="apartment-modal"
      show
      on_cancel={JS.patch(~p"/apartments/#{@apartment}")}
    >
      <.live_component
        module={RentWeb.ApartmentLive.FormComponent}
        id={@apartment.id}
        title={@page_title}
        action={@live_action}
        apartment={@apartment}
        patch={~p"/apartments/#{@apartment}"}
      />
    </.modal>

    <.modal
      :if={@live_action in [:new_house, :edit_house]}
      id="house-modal"
      show
      on_cancel={JS.patch(~p"/apartments/#{@apartment}")}
    >
      <.live_component
        module={RentWeb.HouseLive.FormComponent}
        id={@house.id || :new}
        title={@page_title}
        action={@live_action}
        house={@house}
        apartment={@apartment}
        patch={~p"/apartments/#{@apartment}"}
      />
    </.modal>
    """
  end

  # House status badge component
  attr :status, :string, required: true

  defp house_status_badge(assigns) do
    ~H"""
    <span class={[
      "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
      case @status do
        false -> "bg-green-100 text-green-800"
        _ -> "bg-orange-100 text-orange-800"
      end
    ]}>
      <div class={[
        "w-1.5 h-1.5 rounded-full mr-1.5",
        case @status do
          false -> "bg-green-400"
          _ -> "bg-orange-400"
        end
      ]}>
      </div>
      <%= if @status != true do %>
        Occupied
      <% else %>
        Vacant
      <% end %>
    </span>
    """
  end
end
