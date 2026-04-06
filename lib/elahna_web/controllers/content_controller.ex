defmodule ElahnaWeb.ContentController do
  use ElahnaWeb, :controller
  alias ElahnaWeb.FileGuard

  def show_md(conn, %{"filename" => filename}) do
    base_dir = storage_path()

    case FileGuard.safe_path(base_dir, filename <> ".md") do
      {:ok, path} ->
        content = File.read!(path)
        html = Elahna.Markdown.to_html!(content)

        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, html)

      {:error, :not_found} ->
        send_resp(conn, 404, "Markdown file not found")
    end
  end

  def show_xml(conn, %{"filename" => filename}) do
    base_dir = storage_path()

    case FileGuard.safe_path(base_dir, filename <> ".xml") do
      {:ok, path} ->
        content = File.read!(path)

        conn
        |> put_resp_content_type("text/xml")
        |> send_resp(200, content)

      {:error, :not_found} ->
        send_resp(conn, 404, "XML file not found")
    end
  end
end
