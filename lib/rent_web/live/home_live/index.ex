defmodule RentWeb.HomeLive.Index do
  use RentWeb, :live_view

  alias Rent.Apartments
  alias Rent.Houses

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Rent Payment Portal")
      |> assign(:selected_apartment, nil)
      |> assign(:selected_house, nil)
      |> assign(:apartments, Apartments.list_apartments())
      |> assign(:houses, [])
      |> assign(:step, 1)
      |> assign(:show_payment_modal, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("select_apartment", %{"apartment_id" => apartment_id}, socket) do
    apartment = Apartments.get_apartment!(apartment_id)
    houses = Houses.list_houses_by_apartment(apartment_id)

    socket =
      socket
      |> assign(:selected_apartment, apartment)
      |> assign(:houses, houses)
      |> assign(:selected_house, nil)
      |> assign(:step, 2)

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_house", %{"house_id" => house_id}, socket) do
    house = Houses.get_house!(house_id)

    socket =
      socket
      |> assign(:selected_house, house)
      |> assign(:step, 3)

    {:noreply, socket}
  end

  @impl true
  def handle_event("reset_selection", _params, socket) do
    socket =
      socket
      |> assign(:selected_apartment, nil)
      |> assign(:selected_house, nil)
      |> assign(:houses, [])
      |> assign(:step, 1)
      |> assign(:show_payment_modal, false)

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_payment_modal", _params, socket) do
    {:noreply, assign(socket, :show_payment_modal, true)}
  end

  @impl true
  def handle_event("close_payment_modal", _params, socket) do
    {:noreply, assign(socket, :show_payment_modal, false)}
  end

  @impl true
  def handle_info({RentWeb.TenantPaymentLive.FormComponent, {:saved, _payment}}, socket) do
    {:noreply,
     socket
     |> assign(:show_payment_modal, false)
     |> put_flash(:info, "Payment completed successfully!")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <!-- Header -->
      <div class="bg-white shadow-sm">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex justify-between items-center py-6">
            <div class="flex items-center space-x-3">
              <div class="w-10 h-10 bg-blue-600 rounded-lg flex items-center justify-center">
                <.icon name="hero-building-office-2" class="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 class="text-xl font-bold text-gray-900">Rent</h1>
                <p class="text-sm text-gray-600">Tenant Payment Portal</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      
    <!-- Main Content -->
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <!-- Welcome Section -->
        <div class="text-center mb-12">
          <h2 class="text-3xl font-bold text-gray-900 mb-4">
            Welcome to Your Rent Payment Portal
          </h2>
          <p class="text-lg text-gray-600 max-w-2xl mx-auto">
            Pay your rent quickly and securely online. Simply select your apartment complex,
            choose your house, and proceed with your payment.
          </p>
        </div>
        
    <!-- Progress Steps -->
        <div class="flex justify-center mb-12">
          <div class="flex items-center space-x-4">
            <!-- Step 1 -->
            <div class="flex items-center">
              <div class={[
                "w-10 h-10 rounded-full flex items-center justify-center text-sm font-medium",
                if(@step >= 1, do: "bg-blue-600 text-white", else: "bg-gray-300 text-gray-600")
              ]}>
                1
              </div>
              <span class="ml-2 text-sm font-medium text-gray-900">Select Apartment</span>
            </div>

            <div class="w-8 h-0.5 bg-gray-300"></div>
            
    <!-- Step 2 -->
            <div class="flex items-center">
              <div class={[
                "w-10 h-10 rounded-full flex items-center justify-center text-sm font-medium",
                if(@step >= 2, do: "bg-blue-600 text-white", else: "bg-gray-300 text-gray-600")
              ]}>
                2
              </div>
              <span class="ml-2 text-sm font-medium text-gray-900">Select House</span>
            </div>

            <div class="w-8 h-0.5 bg-gray-300"></div>
            
    <!-- Step 3 -->
            <div class="flex items-center">
              <div class={[
                "w-10 h-10 rounded-full flex items-center justify-center text-sm font-medium",
                if(@step >= 3, do: "bg-blue-600 text-white", else: "bg-gray-300 text-gray-600")
              ]}>
                3
              </div>
              <span class="ml-2 text-sm font-medium text-gray-900">Make Payment</span>
            </div>
          </div>
        </div>
        
    <!-- Step 1: Select Apartment -->
        <div :if={@step == 1} class="bg-white rounded-lg shadow-sm border border-gray-200 p-8 mb-8">
          <div class="text-center mb-6">
            <.icon name="hero-building-office" class="mx-auto h-12 w-12 text-blue-600 mb-4" />
            <h3 class="text-xl font-semibold text-gray-900">Step 1: Select Your Apartment Complex</h3>
            <p class="text-gray-600 mt-2">Choose the apartment complex where you live</p>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <button
              :for={apartment <- @apartments}
              phx-click="select_apartment"
              phx-value-apartment_id={apartment.id}
              class="p-6 border-2 border-gray-200 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-colors duration-200 text-left"
            >
              <div class="flex items-center mb-3">
                <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center mr-3">
                  <.icon name="hero-building-office" class="w-6 h-6 text-blue-600" />
                </div>
                <div>
                  <h4 class="font-semibold text-gray-900">{apartment.name}</h4>
                </div>
              </div>
              <p class="text-sm text-gray-600">{apartment.location}</p>
              <div class="mt-3 text-blue-600 text-sm font-medium">
                Select this complex →
              </div>
            </button>
          </div>
        </div>
        
    <!-- Step 2: Select House -->
        <div :if={@step == 2} class="bg-white rounded-lg shadow-sm border border-gray-200 p-8 mb-8">
          <div class="flex items-center justify-between mb-6">
            <div class="text-center flex-1">
              <.icon name="hero-home" class="mx-auto h-12 w-12 text-green-600 mb-4" />
              <h3 class="text-xl font-semibold text-gray-900">Step 2: Select Your House</h3>
              <p class="text-gray-600 mt-2">
                Choose your house in <span class="font-medium">{@selected_apartment.name}</span>
              </p>
            </div>
            <button phx-click="reset_selection" class="ml-4 text-sm text-gray-500 hover:text-gray-700">
              ← Change apartment
            </button>
          </div>

          <div :if={Enum.empty?(@houses)} class="text-center py-8">
            <.icon name="hero-home" class="mx-auto h-12 w-12 text-gray-400 mb-4" />
            <h4 class="text-lg font-medium text-gray-900 mb-2">No houses found</h4>
            <p class="text-gray-600">There are no houses registered in this apartment complex yet.</p>
          </div>

          <div
            :if={not Enum.empty?(@houses)}
            class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4"
          >
            <button
              :for={house <- @houses}
              phx-click="select_house"
              phx-value-house_id={house.id}
              class="p-6 border-2 border-gray-200 rounded-lg hover:border-green-500 hover:bg-green-50 transition-colors duration-200 text-left"
            >
              <div class="flex items-center mb-3">
                <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center mr-3">
                  <.icon name="hero-home" class="w-6 h-6 text-green-600" />
                </div>
                <div>
                  <h4 class="font-semibold text-gray-900">{house.name}</h4>
                </div>
              </div>
              <div :if={house.tenant && house.tenant != ""} class="mb-3">
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                  <.icon name="hero-user" class="w-3 h-3 mr-1" />
                  {house.tenant}
                </span>
              </div>
              <div class="text-green-600 text-sm font-medium">
                Select this house →
              </div>
            </button>
          </div>
        </div>
        
    <!-- Step 3: Make Payment -->
        <div :if={@step == 3} class="bg-white rounded-lg shadow-sm border border-gray-200 p-8">
          <div class="text-center mb-8">
            <.icon name="hero-credit-card" class="mx-auto h-12 w-12 text-purple-600 mb-4" />
            <h3 class="text-xl font-semibold text-gray-900">Step 3: Make Your Payment</h3>
            <p class="text-gray-600 mt-2">Ready to pay rent for your selected property</p>
          </div>
          
    <!-- Selected Property Summary -->
          <div class="bg-gray-50 rounded-lg p-6 mb-8">
            <h4 class="font-semibold text-gray-900 mb-4">Selected Property:</h4>
            <div class="space-y-2">
              <div class="flex items-center text-sm">
                <.icon name="hero-building-office" class="w-4 h-4 text-blue-600 mr-2" />
                <span class="font-medium">Apartment:</span>
                <span class="ml-2">{@selected_apartment.name}</span>
              </div>
              <div class="flex items-center text-sm">
                <.icon name="hero-map-pin" class="w-4 h-4 text-gray-600 mr-2" />
                <span class="font-medium">Location:</span>
                <span class="ml-2">{@selected_apartment.location}</span>
              </div>
              <div class="flex items-center text-sm">
                <.icon name="hero-home" class="w-4 h-4 text-green-600 mr-2" />
                <span class="font-medium">House:</span>
                <span class="ml-2">{@selected_house.name}</span>
              </div>
              <div
                :if={@selected_house.tenant && @selected_house.tenant != ""}
                class="flex items-center text-sm"
              >
                <.icon name="hero-user" class="w-4 h-4 text-purple-600 mr-2" />
                <span class="font-medium">Tenant:</span>
                <span class="ml-2">{@selected_house.tenant}</span>
              </div>

              <div :if={@selected_house.rent_amount} class="flex items-center text-sm">
                <.icon name="hero-banknotes" class="w-4 h-4 text-yellow-600 mr-2" />
                <span class="font-medium">Rent Amount:</span>
                <span class="ml-2">KES {@selected_house.rent_amount}/month</span>
              </div>
            </div>
          </div>
          
    <!-- Payment Button -->
          <div class="text-center">
            <button
              phx-click="show_payment_modal"
              class="bg-purple-600 hover:bg-purple-700 text-white text-lg px-8 py-4 rounded-lg font-semibold transition-colors duration-200"
            >
              <.icon name="hero-credit-card" class="w-5 h-5 mr-2" /> Make Payment
            </button>

            <div class="mt-4 flex justify-center space-x-4">
              <button phx-click="reset_selection" class="text-sm text-gray-500 hover:text-gray-700">
                ← Start over
              </button>
            </div>
          </div>
        </div>
        
    <!-- Info Section -->
        <div class="mt-16 bg-blue-50 rounded-lg p-8">
          <div class="text-center">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">How It Works</h3>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div class="text-center">
                <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mx-auto mb-3">
                  <.icon name="hero-building-office" class="w-6 h-6 text-blue-600" />
                </div>
                <h4 class="font-medium text-gray-900 mb-2">Select Your Complex</h4>
                <p class="text-sm text-gray-600">Choose your apartment complex from the list</p>
              </div>
              <div class="text-center">
                <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center mx-auto mb-3">
                  <.icon name="hero-home" class="w-6 h-6 text-green-600" />
                </div>
                <h4 class="font-medium text-gray-900 mb-2">Choose Your House</h4>
                <p class="text-sm text-gray-600">Select the specific house unit you rent</p>
              </div>
              <div class="text-center">
                <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center mx-auto mb-3">
                  <.icon name="hero-credit-card" class="w-6 h-6 text-purple-600" />
                </div>
                <h4 class="font-medium text-gray-900 mb-2">Secure Payment</h4>
                <p class="text-sm text-gray-600">Pay your rent safely and get instant confirmation</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      
    <!-- Payment Modal -->
      <.modal
        :if={@show_payment_modal and @selected_house}
        id="payment-modal"
        show
        on_cancel={JS.push("close_payment_modal")}
      >
        <.live_component
          module={RentWeb.TenantPaymentLive.FormComponent}
          id={:payment}
          house={@selected_house}
          patch={~p"/"}
        />
      </.modal>
    </div>
    """
  end
end
