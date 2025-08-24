defmodule RentWeb.ApartmentLive.FormComponent do
  use RentWeb, :live_component

  alias Rent.Apartments

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="mb-6">
        <h3 class="text-lg font-semibold text-gray-900">
          {@title}
        </h3>
        <p class="mt-1 text-sm text-gray-600">
          <%= if @action == :new do %>
            Add a new apartment unit to your property portfolio.
          <% else %>
            Update the apartment unit information.
          <% end %>
        </p>
      </div>

      <.simple_form
        for={@form}
        id="apartment-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="space-y-6">
          <.input
            field={@form[:name]}
            type="text"
            label="Apartment Name"
            placeholder="e.g., Sunset Apartments, Downtown Loft, etc."
            required
          />

          <.input
            field={@form[:location]}
            type="text"
            label="Location"
            placeholder="e.g., 123 Main Street, Building A, Floor 2"
            required
          />
        </div>
        
    <!-- Form Actions -->
        <div class="flex items-center justify-end space-x-3 pt-6 border-t border-gray-200 mt-6">
          <button
            type="button"
            phx-click={JS.patch(@patch)}
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            Cancel
          </button>
          <.button phx-disable-with="Saving..." class="bg-blue-600 hover:bg-blue-700 text-white">
            {if @action == :new, do: "Create Apartment", else: "Save Changes"}
          </.button>
        </div>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{apartment: apartment} = assigns, socket) do
    changeset = Apartments.change_apartment(apartment)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"apartment" => apartment_params}, socket) do
    changeset =
      socket.assigns.apartment
      |> Apartments.change_apartment(apartment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"apartment" => apartment_params}, socket) do
    save_apartment(socket, socket.assigns.action, apartment_params)
  end

  defp save_apartment(socket, :edit, apartment_params) do
    case Apartments.update_apartment(socket.assigns.apartment, apartment_params) do
      {:ok, apartment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Apartment updated successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_apartment(socket, :new, apartment_params) do
    case Apartments.create_apartment(apartment_params) do
      {:ok, apartment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Apartment created successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
