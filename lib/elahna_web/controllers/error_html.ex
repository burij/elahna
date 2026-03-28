defmodule ElahnaWeb.ErrorHTML do
  use Phoenix.Controller, formats: [:html], layouts: []

  def render("404.html", %{conn: _conn}) do
    "Page not found"
  end
end
