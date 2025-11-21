defmodule ProviderLookupWeb.PageController do
  use ProviderLookupWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
