defmodule RentWeb.TenantPaymentLive.FormComponent do
  use RentWeb, :live_component

  alias Rent.Payments
  alias Rent.Apartments
  alias Rent.Houses

  @months [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="mb-6">
        <h3 class="text-xl font-bold text-gray-900">
          Make Your Rent Payment
        </h3>
        <p class="mt-1 text-sm text-gray-600">
          Select the months you want to pay for and complete your payment securely.
        </p>
      </div>
      
    <!-- Property Information -->
      <div class="bg-blue-50 rounded-lg p-4 mb-6">
        <h4 class="font-semibold text-gray-900 mb-3">Payment For:</h4>
        <div class="space-y-2 text-sm">
          <div class="flex items-center">
            <.icon name="hero-building-office" class="w-4 h-4 text-blue-600 mr-2" />
            <span class="font-medium">Apartment:</span>
            <span class="ml-2">{@house.apartment.name}</span>
          </div>
          <div class="flex items-center">
            <.icon name="hero-home" class="w-4 h-4 text-green-600 mr-2" />
            <span class="font-medium">House:</span>
            <span class="ml-2">{@house.name}</span>
          </div>
          <div class="flex items-center">
            <.icon name="hero-map-pin" class="w-4 h-4 text-gray-600 mr-2" />
            <span class="font-medium">Location:</span>
            <span class="ml-2">{@house.apartment.location}</span>
          </div>

          <div class="flex items-center">
            <.icon name="hero-user" class="w-4 h-4 text-purple-600 mr-2" />
            <span class="font-medium">Tenant:</span>
            <span class="ml-2">{@house.tenant || "N/A"}</span>
          </div>

          <div class="flex items-center">
            <.icon name="hero-currency-dollar" class="w-4 h-4 text-yellow-600 mr-2" />
            <span class="font-medium">Current Rent Amount:</span>
            <span class="ml-2">
              KES {@house.rent_amount} KES /=
            </span>
          </div>
        </div>
      </div>

      <.simple_form
        for={@form}
        id="payment-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="space-y-6">
          <!-- Month Selection -->
          <div>
            <label class="block text-sm font-medium text-gray-900 mb-3">
              Select Months to Pay For
            </label>
            <div class="grid grid-cols-2 md:grid-cols-3 gap-3">
              <label
                :for={month <- @months}
                class="relative flex items-center p-3 border border-gray-300 rounded-lg cursor-pointer hover:bg-gray-50 focus-within:ring-2 focus-within:ring-blue-500"
              >
                <input
                  type="checkbox"
                  name="selected_months[]"
                  value={month}
                  checked={month in @selected_months}
                  phx-target={@myself}
                  phx-change="toggle_month"
                  class="sr-only"
                />
                <div class={[
                  "w-4 h-4 rounded border-2 mr-3 flex items-center justify-center",
                  if(month in @selected_months,
                    do: "bg-blue-600 border-blue-600",
                    else: "border-gray-300"
                  )
                ]}>
                  <.icon :if={month in @selected_months} name="hero-check" class="w-3 h-3 text-white" />
                </div>
                <span class={[
                  "text-sm font-medium",
                  if(month in @selected_months, do: "text-blue-600", else: "text-gray-900")
                ]}>
                  {month} {Date.utc_today().year}
                </span>
              </label>
            </div>
            <p class="mt-2 text-xs text-gray-500">
              Select multiple months to pay in advance. Each month will be recorded as a separate payment.
            </p>
          </div>
          
    <!-- Payment Summary -->
          <div :if={not Enum.empty?(@selected_months)} class="bg-gray-50 rounded-lg p-4">
            <h4 class="font-semibold text-gray-900 mb-3">Payment Summary</h4>
            <div class="space-y-2">
              <div :for={month <- @selected_months} class="flex justify-between items-center text-sm">
                <span>{month} {Date.utc_today().year}</span>
                <span class="font-medium">
                  KES{:erlang.float_to_binary(@monthly_amount, decimals: 2)}
                </span>
              </div>
              <div class="border-t border-gray-300 pt-2 mt-2">
                <div class="flex justify-between items-center font-semibold text-base">
                  <span>Total Amount</span>
                  <span class="text-blue-600">
                    KES{:erlang.float_to_binary(@monthly_amount * length(@selected_months),
                      decimals: 2
                    )}
                  </span>
                </div>
                <p class="text-xs text-gray-500 mt-1">
                  {length(@selected_months)} payment{if length(@selected_months) > 1, do: "s"} will be created
                </p>
              </div>
            </div>
          </div>
          
    <!-- Monthly Rent Amount -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="flex flex-col justify-end">
              <div class="text-sm text-gray-600 bg-blue-50 rounded-md p-3">
                <div class="flex items-center">
                  <.icon name="hero-information-circle" class="w-4 h-4 text-blue-600 mr-2" />
                  <span>This amount will be applied to each selected month</span>
                </div>
              </div>
            </div>
          </div>
          
    <!-- Customer Information -->
          <div class="pt-6 border-t border-gray-200">
            <h4 class="text-sm font-medium text-gray-900 mb-4">Your Information</h4>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <.input
                field={@form[:customer_name]}
                type="text"
                label="Full Name"
                placeholder="e.g., John Smith"
                required
              />

              <.input
                field={@form[:customer_email]}
                type="email"
                label="Email Address"
                placeholder="e.g., john@example.com"
                required
              />
            </div>

            <.input
              field={@form[:customer_phone_number]}
              type="tel"
              label="Phone Number"
              placeholder="e.g., (555) 123-4567"
            />
          </div>
          
    <!-- Payment Method Simulation -->
          <div class="pt-6 border-t border-gray-200">
            <h4 class="text-sm font-medium text-gray-900 mb-4">Payment Method</h4>
            <div class="bg-green-50 border border-green-200 rounded-lg p-4">
              <div class="flex items-center">
                <.icon name="hero-credit-card" class="w-5 h-5 text-green-600 mr-2" />
                <span class="text-sm text-green-800 font-medium">
                  Secure Payment Processing
                </span>
              </div>
              <p class="text-xs text-green-700 mt-1">
                Your payment will be processed securely. For this demo, clicking "Process Payment" will simulate a successful transaction.
              </p>
            </div>
          </div>
        </div>
        
    <!-- Hidden field for house_id -->
        <input type="hidden" name="house_id" value={@house.id} />
        
    <!-- Form Actions -->
        <div class="flex items-center justify-between pt-6 border-t border-gray-200 mt-6">
          <div class="text-sm text-gray-500">
            <%= if not Enum.empty?(@selected_months) do %>
              Total: KES{:erlang.float_to_binary(@monthly_amount * length(@selected_months),
                decimals: 2
              )} for {length(@selected_months)} month{if length(@selected_months) > 1, do: "s"}
            <% else %>
              Select months to see total
            <% end %>
          </div>
          <div class="flex space-x-3">
            <button
              type="button"
              phx-click={JS.patch(@patch)}
              class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Cancel
            </button>
            <.button
              disabled={Enum.empty?(@selected_months) or @monthly_amount <= 0}
              phx-disable-with="Processing Payment..."
              class="bg-blue-600 hover:bg-blue-700 text-white disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <.icon name="hero-credit-card" class="w-4 h-4 mr-2" /> Process Payment
            </.button>
          </div>
        </div>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{house: house} = assigns, socket) do
    house_with_apartment = Houses.get_house_with_apartment(house.id)

    socket =
      socket
      |> assign(assigns)
      |> assign(:house, house_with_apartment)
      |> assign(:selected_months, [])
      # Default amount
      |> assign(
        :monthly_amount,
        house.rent_amount |> :erlang.float()
      )
      |> assign(:months, @months)
      |> assign_form()

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle_month", %{"selected_months" => selected_months}, socket) do
    month = List.last(selected_months)

    selected_months =
      if month in socket.assigns.selected_months do
        List.delete(socket.assigns.selected_months, month)
      else
        [month | socket.assigns.selected_months]
        |> Enum.sort_by(&Enum.find_index(@months, fn m -> m == &1 end))
      end

    {:noreply, assign(socket, :selected_months, selected_months)}
  end

  @impl true
  def handle_event(
        "update_amount",
        %{"_target" => ["monthly_amount"], "monthly_amount" => amount},
        socket
      ) do
    monthly_amount =
      case Float.parse(amount) do
        {amt, _} -> amt
        :error -> 0.0
      end

    {:noreply, assign(socket, :monthly_amount, monthly_amount)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"customer_name" => name, "customer_email" => email, "customer_phone_number" => phone},
        socket
      ) do
    # Just update form state for validation
    socket =
      socket
      |> assign(:customer_name, name)
      |> assign(:customer_email, email)
      |> assign(:customer_phone_number, phone)

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", params, socket) do
    %{
      "customer_name" => customer_name,
      "customer_email" => customer_email,
      "customer_phone_number" => customer_phone_number,
      "house_id" => house_id
    } = params

    # Validate required fields
    cond do
      Enum.empty?(socket.assigns.selected_months) ->
        {:noreply, put_flash(socket, :error, "Please select at least one month to pay for.")}

      socket.assigns.monthly_amount <= 0 ->
        {:noreply, put_flash(socket, :error, "Please enter a valid payment amount.")}

      customer_name == "" or customer_email == "" ->
        {:noreply, put_flash(socket, :error, "Please fill in all required fields.")}

      true ->
        create_payments(socket, %{
          house_id: house_id,
          customer_name: customer_name,
          customer_email: customer_email,
          customer_phone_number: customer_phone_number,
          monthly_amount: socket.assigns.monthly_amount,
          selected_months: socket.assigns.selected_months
        })
    end
  end

  defp create_payments(socket, payment_data) do
    %{
      house_id: house_id,
      customer_name: customer_name,
      customer_email: customer_email,
      customer_phone_number: customer_phone_number,
      monthly_amount: monthly_amount,
      selected_months: selected_months
    } = payment_data

    # Create individual payment records for each selected month
    results =
      Enum.map(selected_months, fn month ->
        payment_params = %{
          house_id: house_id,
          month: "#{month} #{Date.utc_today().year}",
          customer_name: customer_name,
          customer_email: customer_email,
          customer_phone_number: customer_phone_number,
          # Convert to cents
          amount: trunc(monthly_amount * 100),
          # Mark as complete since payment is "processed"
          is_complete: true
        }

        Payments.create_payment(payment_params)
      end)

    # Check if all payments were created successfully
    case Enum.all?(results, fn {status, _} -> status == :ok end) do
      true ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Payment successful! #{length(selected_months)} payment(s) have been processed."
         )
         |> push_redirect(to: "/")}

      false ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "There was an error processing your payment. Please try again."
         )}
    end
  end

  defp assign_form(socket) do
    # Create a basic form structure for validation
    form_data = %{
      customer_name: "",
      customer_email: "",
      customer_phone_number: "",
      monthly_amount: socket.assigns.monthly_amount
    }

    assign(socket, :form, to_form(form_data))
  end
end
