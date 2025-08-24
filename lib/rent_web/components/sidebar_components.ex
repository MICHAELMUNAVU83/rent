defmodule RentWeb.Components.Sidebar do
  use Phoenix.Component
  import RentWeb.CoreComponents

  attr :current_path, :string, required: true
  attr :class, :string, default: ""

  def sidebar(assigns) do
    ~H"""
    <aside class={["w-64 bg-white border-r border-gray-200 flex flex-col h-screen", @class]}>
      <!-- Logo/Brand Section -->
      <div class="p-6 border-b border-gray-200">
        <div class="flex items-center space-x-3">
          <div class="w-10 h-10 bg-blue-600 rounded-lg flex items-center justify-center">
            <.icon name="hero-building-office-2" class="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 class="text-xl font-semibold text-gray-900">RentManager</h1>
            <p class="text-sm text-gray-500">Property Management</p>
          </div>
        </div>
      </div>
      
    <!-- Navigation Menu -->
      <nav class="flex-1 px-4 py-6 space-y-2">
        <.nav_item
          path="/dashboard"
          current_path={@current_path}
          icon="hero-chart-pie"
          label="Dashboard"
        />

        <.nav_item
          path="/apartments"
          current_path={@current_path}
          icon="hero-building-office"
          label="Apartments"
        />

        <.nav_item path="/houses" current_path={@current_path} icon="hero-home" label="Houses" />

        <.nav_item
          path="/payments"
          current_path={@current_path}
          icon="hero-credit-card"
          label="Payments"
        />
        
    <!-- Divider -->
        <div class="border-t border-gray-200 my-4"></div>

        <.nav_item path="/tenants" current_path={@current_path} icon="hero-users" label="Tenants" />

        <.nav_item
          path="/reports"
          current_path={@current_path}
          icon="hero-document-chart-bar"
          label="Reports"
        />

        <.nav_item
          path="/settings"
          current_path={@current_path}
          icon="hero-cog-6-tooth"
          label="Settings"
        />
      </nav>
      
    <!-- User Profile Section -->
      <div class="p-4 border-t border-gray-200">
        <div class="flex items-center space-x-3">
          <div class="w-9 h-9 bg-gray-300 rounded-full flex items-center justify-center">
            <.icon name="hero-user" class="w-5 h-5 text-gray-600" />
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-gray-900 truncate">Admin User</p>
            <p class="text-xs text-gray-500 truncate">admin@example.com</p>
          </div>
          <button class="text-gray-400 hover:text-gray-600">
            <.icon name="hero-ellipsis-vertical" class="w-5 h-5" />
          </button>
        </div>
      </div>
    </aside>
    """
  end

  attr :path, :string, required: true
  attr :current_path, :string, required: true
  attr :icon, :string, required: true
  attr :label, :string, required: true

  defp nav_item(assigns) do
    ~H"""
    <.link
      navigate={@path}
      class={[
        "flex items-center px-3 py-2.5 text-sm font-medium rounded-lg transition-colors duration-200",
        if(@current_path == @path,
          do: "bg-blue-50 text-blue-700 border-r-2 border-blue-700",
          else: "text-gray-700 hover:bg-gray-50 hover:text-gray-900"
        )
      ]}
    >
      <.icon
        name={@icon}
        class={[
          "w-5 h-5 mr-3",
          if(@current_path == @path, do: "text-blue-600", else: "text-gray-500")
        ]}
      />
      {@label}
    </.link>
    """
  end
end
