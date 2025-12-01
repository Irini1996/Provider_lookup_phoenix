defmodule ProviderLookupWeb.Router do
  use ProviderLookupWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ProviderLookupWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

scope "/", ProviderLookupWeb do
  pipe_through :browser

  get "/", ProviderController, :search
  get "/search", ProviderController, :search
  get "/providers/:npi", ProviderController, :show
end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:provider_lookup, :dev_routes) do

    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ProviderLookupWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
