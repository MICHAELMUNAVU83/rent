defmodule RentWeb.Router do
  use RentWeb, :router

  import RentWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RentWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RentWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/apartments", ApartmentLive.Index, :index
    live "/apartments/new", ApartmentLive.Index, :new
    live "/apartments/:id/edit", ApartmentLive.Index, :edit

    live "/apartments/:id", ApartmentLive.Show, :show
    live "/apartments/:id/show/edit", ApartmentLive.Show, :edit

    live "/apartments/:id/houses/new", ApartmentLive.Show, :new_house
    live "/apartments/:id/houses/:house_id/edit", ApartmentLive.Show, :edit_house

    live "/houses", HouseLive.Index, :index
    live "/houses/new", HouseLive.Index, :new
    live "/houses/:id/edit", HouseLive.Index, :edit

    live "/houses/:id", HouseLive.Show, :show
    live "/houses/:id/show/edit", HouseLive.Show, :edit

    live "/payments", PaymentLive.Index, :index
    live "/payments/new", PaymentLive.Index, :new
    live "/payments/:id/edit", PaymentLive.Index, :edit

    live "/payments/:id", PaymentLive.Show, :show
    live "/payments/:id/show/edit", PaymentLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", RentWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:rent, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RentWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", RentWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{RentWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", RentWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{RentWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", RentWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{RentWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
