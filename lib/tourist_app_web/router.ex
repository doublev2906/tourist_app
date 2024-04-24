defmodule TouristAppWeb.Router do
  use TouristAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TouristAppWeb.Layouts, :root}
    # plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TouristAppWeb do
    pipe_through :browser

    get "/", PageController, :home

    scope "/user" do
      post "/login", UserController, :login
      post "/sign_up", UserController, :sign_up
      post "/favorite_destination", UserController, :favorite_destination
    end

    scope "/home" do
      get "/", HomeController, :index
      get "/activities", HomeController, :get_activities
      get "/destinations", HomeController, :get_destinations
    end

    scope "/city" do
      get "/get_list_city", CityController, :get_list_city
      get "/all_city", CityController, :get_all_city
      get "/:city_id", CityController, :get_city_detail
    end

    scope "/trips" do
      get "/", TripController, :index
      post "/create", TripController, :create
      scope "/:id" do
        get "/", TripController, :show
        post "/update", TripController, :update
      end
    end

    scope "/destination" do
      scope "/detail" do
        get "/:id", DestinationController, :index
      end
      post "/review", DestinationController, :add_destination_review
      get "/get_list_destination", DestinationController, :get_list_destination
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", TouristAppWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:tourist_app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TouristAppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
