defmodule RentWeb.HouseLive.FormComponent do
  use RentWeb, :live_component

  alias Rent.Houses
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
          <%= if @action in [:new_house] do %>
            Add a new house to {@apartment.name} for payment tracking.
          <% else %>
            Update the house information.
          <% end %>
        </p>
      </div>

      <.simple_form
        for={@form}
        id="house-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="space-y-6">
          <.input
            :if={@apartment == nil}
            field={@form[:apartment_id]}
            type="select"
            label="Apartment"
            options={Enum.map(Apartments.list_apartments(), &{&1.name, &1.id})}
            prompt="Select an Apartment"
            required
          />

          <.input
            field={@form[:name]}
            type="text"
            label="House Name"
            placeholder="e.g., House A, Unit 101, Blue House, etc."
            required
          />

          <.input
            field={@form[:tenant]}
            type="text"
            label="Tenant Name"
            placeholder="e.g., John Smith"
          />

          <.input
            field={@form[:rent_amount]}
            type="number"
            label="Rent Amount (KES)"
            placeholder="e.g., 40000"
            min="0"
            step="1"
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
            {if @action in [:new_house], do: "Create House", else: "Save Changes"}
          </.button>
        </div>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{house: house} = assigns, socket) do
    changeset = Houses.change_house(house)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"house" => house_params}, socket) do
    changeset =
      socket.assigns.house
      |> Houses.change_house(house_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"house" => house_params}, socket) do
    house_params =
      Map.put(
        house_params,
        "apartment_id",
        (socket.assigns.apartment && socket.assigns.apartment.id) || house_params["apartment_id"]
      )

    save_house(socket, socket.assigns.action, house_params)
  end

  defp save_house(socket, action, house_params) when action in [:edit_house, :edit] do
    case Houses.update_house(socket.assigns.house, house_params) do
      {:ok, house} ->
        {:noreply,
         socket
         |> put_flash(:info, "House updated successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_house(socket, :new_house, house_params) do
    case Houses.create_house(house_params) do
      {:ok, house} ->
        {:noreply,
         socket
         |> put_flash(:info, "House created successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_house(socket, :new, house_params) do
    case Houses.create_house(house_params) do
      {:ok, house} ->
        {:noreply,
         socket
         |> put_flash(:info, "House created successfully")
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
