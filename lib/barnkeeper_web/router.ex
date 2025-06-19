defmodule BarnkeeperWeb.Router do
  use BarnkeeperWeb, :router

  import BarnkeeperWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BarnkeeperWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BarnkeeperWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", BarnkeeperWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:barnkeeper, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BarnkeeperWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", BarnkeeperWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{BarnkeeperWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", BarnkeeperWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{BarnkeeperWeb.UserAuth, :ensure_authenticated}] do
      # Main application routes
      live "/dashboard", DashboardLive, :index
      live "/horses", HorseLive.Index, :index
      live "/horses/new", HorseLive.Index, :new
      live "/horses/:id/edit", HorseLive.Index, :edit
      live "/horses/:id", HorseLive.Show, :show
      live "/horses/:id/show/edit", HorseLive.Show, :edit
      live "/horses/:id/photos/upload", HorseLive.Show, :upload_photos

      # Vet visits
      live "/vet_visits", VetVisitLive.Index, :index
      live "/vet_visits/new", VetVisitLive.Index, :new
      live "/vet_visits/:id/edit", VetVisitLive.Index, :edit
      live "/vet_visits/:id", VetVisitLive.Show, :show
      live "/vet_visits/:id/show/edit", VetVisitLive.Show, :edit

      # Farrier visits
      live "/farrier_visits", FarrierVisitLive.Index, :index
      live "/farrier_visits/new", FarrierVisitLive.Index, :new
      live "/farrier_visits/:id/edit", FarrierVisitLive.Index, :edit
      live "/farrier_visits/:id", FarrierVisitLive.Show, :show
      live "/farrier_visits/:id/show/edit", FarrierVisitLive.Show, :edit

      # Vaccinations
      live "/vaccinations", VaccinationLive.Index, :index
      live "/vaccinations/new", VaccinationLive.Index, :new
      live "/vaccinations/:id/edit", VaccinationLive.Index, :edit
      live "/vaccinations/:id", VaccinationLive.Show, :show
      live "/vaccinations/:id/show/edit", VaccinationLive.Show, :edit

      # Notes
      live "/notes", NoteLive.Index, :index
      live "/notes/new", NoteLive.Index, :new
      live "/notes/:id/edit", NoteLive.Index, :edit
      live "/notes/:id", NoteLive.Show, :show
      live "/notes/:id/show/edit", NoteLive.Show, :edit

      # Feedings
      live "/feedings", FeedingLive.Index, :index
      live "/feedings/new", FeedingLive.Index, :new
      live "/feedings/:id/edit", FeedingLive.Index, :edit
      live "/feedings/:id", FeedingLive.Show, :show
      live "/feedings/:id/show/edit", FeedingLive.Show, :edit

      # Calendar
      live "/calendar", CalendarLive, :index

      # Team setup
      live "/team/setup", TeamSetupLive, :index

      # User settings
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", BarnkeeperWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{BarnkeeperWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
