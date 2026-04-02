defmodule ElahnaWeb.FileController do
  use ElahnaWeb, :controller
  alias ElahnaWeb.FileGuard

  def file(conn, %{"path" => path_list}) do
    filename = Path.join(path_list)
    ext = Path.extname(filename)

    cond do
      ext == ".md" -> render_md(conn, filename)
      ext == "" && md_exists?(filename) -> render_md(conn, filename <> ".md")
      true -> serve_static(conn, filename)
    end
  end

  defp render_md(conn, filename) do
    case FileGuard.safe_path(storage_path(), filename) do
      {:ok, path} ->
        content = File.read!(path)
        html = MDEx.to_html!(content, render: [unsafe: true], sanitize: nil)

        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, html)

      {:error, :not_found} ->
        send_resp(conn, 404, "Not found")
    end
  end

  defp md_exists?(filename) do
    File.exists?(Path.join(storage_path(), filename <> ".md"))
  end

  defp serve_static(conn, filename) do
    base = Path.expand(storage_path())
    full = Path.expand(Path.join(storage_path(), filename))

    if String.starts_with?(full, base) and File.exists?(full) do
      conn
      |> put_resp_content_type(content_type(filename))
      |> send_resp(200, File.read!(full))
    else
      send_resp(conn, 404, "Not found")
    end
  end

  defp content_type(filename) do
    %{
      ".css" => "text/css",
      ".js" => "application/javascript",
      ".html" => "text/html",
      ".ico" => "image/x-icon",
      ".svg" => "image/svg+xml",
      ".jpg" => "image/jpeg",
      ".png" => "image/png",
      ".gif" => "image/gif",
      ".ttf" => "font/ttf",
      ".woff" => "font/woff",
      ".woff2" => "font/woff2"
    }[Path.extname(filename)] || "application/octet-stream"
  end
end
