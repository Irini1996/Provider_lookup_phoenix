defmodule ProviderLookupWeb do
  @moduledoc """
  The entrypoint for defining your web interface.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  # ---------------------------------------------------------
  # PUBLIC HELPERS (χρησιμοποιούνται από HEEX templates)
  # ---------------------------------------------------------

  def clean_field(nil), do: ""
  def clean_field(""), do: ""

  def clean_field(value) when is_binary(value) do
    value
    |> String.trim()
    |> String.trim_leading("\"")
    |> String.trim_trailing("\"")
    |> String.replace("<UNAVAIL>", "")
    |> String.replace(~r/\s+/, " ")
  end

  # ---------------------------------------------------------
  # CORRECT ADDRESS BASED ON NPI CSV STRUCTURE
  # ---------------------------------------------------------
  def build_address(p) do
    [
      clean_field(p.practice_address_1),
      clean_field(p.practice_address_2),
      clean_field(p.practice_city),
      clean_field(p.practice_state),
      clean_field(p.practice_zip)
    ]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(", ")
  end

  # ---------------------------------------------------------
  # ROUTER
  # ---------------------------------------------------------
  def router do
    quote do
      use Phoenix.Router, helpers: false

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  # ---------------------------------------------------------
  # CHANNEL
  # ---------------------------------------------------------
  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  # ---------------------------------------------------------
  # CONTROLLER
  # ---------------------------------------------------------
  def controller do
    quote do
      use Phoenix.Controller, formats: [:html, :json]
      use Gettext, backend: ProviderLookupWeb.Gettext

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  # ---------------------------------------------------------
  # LIVE VIEW
  # ---------------------------------------------------------
  def live_view do
    quote do
      use Phoenix.LiveView
      unquote(html_helpers())
    end
  end

  # ---------------------------------------------------------
  # LIVE COMPONENT
  # ---------------------------------------------------------
  def live_component do
    quote do
      use Phoenix.LiveComponent
      unquote(html_helpers())
    end
  end

  # ---------------------------------------------------------
  # HTML (Controller rendering .heex templates)
  # ---------------------------------------------------------
  def html do
    quote do
      use Phoenix.Component

      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      unquote(html_helpers())
    end
  end

  # ---------------------------------------------------------
  # HTML HELPERS — imported automatically in .heex
  # ---------------------------------------------------------
  defp html_helpers do
    quote do
      use Gettext, backend: ProviderLookupWeb.Gettext

      import Phoenix.HTML
      import ProviderLookupWeb.CoreComponents

      alias Phoenix.LiveView.JS
      alias ProviderLookupWeb.Layouts

      # Import reusable helpers into templates
      import ProviderLookupWeb,
        only: [
          clean_field: 1,
          build_address: 1
        ]

      unquote(verified_routes())
    end
  end

  # ---------------------------------------------------------
  # VERIFIED ROUTES
  # ---------------------------------------------------------
  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ProviderLookupWeb.Endpoint,
        router: ProviderLookupWeb.Router,
        statics: ProviderLookupWeb.static_paths()
    end
  end

  # ---------------------------------------------------------
  # USING DISPATCH
  # ---------------------------------------------------------
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
