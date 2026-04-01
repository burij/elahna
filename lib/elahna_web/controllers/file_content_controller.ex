defmodule ElahnaWeb.FileContentController do
  use ElahnaWeb, :controller
  alias ElahnaWeb.FileGuard

  defp storage_path do
    Application.get_env(:elahna, :content_storage) ||
      Application.app_dir(:elahna, "priv/content")
  end

  def index(conn, _params) do
    html_path = Path.join(storage_path(), "index.html")
    version = Application.spec(:elahna, :vsn) |> List.to_string()

    if File.exists?(html_path) do
      content =
        html_path
        |> File.read!()
        |> String.replace("$VERSION", version)

      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, content)
    else
      send_resp(conn, 404, "Index file not found")
    end
  end

  def favicon(conn, _params) do
    favicon_path = Path.join(storage_path(), "favicon.ico")

    if File.exists?(favicon_path) do
      content = File.read!(favicon_path)

      conn
      |> put_resp_content_type("image/x-icon")
      |> send_resp(200, content)
    else
      send_resp(conn, 404, "Not found")
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

  def show_md(conn, %{"filename" => filename}) do
    base_dir = storage_path()

    case FileGuard.safe_path(base_dir, filename <> ".md") do
      {:ok, path} ->
        content = File.read!(path)
        html = Earmark.as_html!(content)

        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, html)

      {:error, :not_found} ->
        send_resp(conn, 404, "Markdown file not found")
    end
  end

  def countletters(conn, %{"string" => data}) do
    count =
      data
      |> String.graphemes()
      |> Enum.count(&Regex.match?(~r/[a-zA-Z]/, &1))

    template_path = Path.join(storage_path(), "count.xml")

    result =
      if File.exists?(template_path) do
        template = File.read!(template_path)

        template
        |> String.replace("$USERINPUT", data)
        |> String.replace("$VALUE", to_string(count))
      else
        "<div><p>Input: #{data}</p><p>Letter count: #{count}</p></div>"
      end

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, result)
  end
end
