defmodule ElahnaWeb.FileController do
  use ElahnaWeb, :controller

  def file(conn, %{"path" => path_list}) do
    filename = Path.join(path_list)
    base_path = Path.expand(storage_path())
    full_path = Path.expand(Path.join(storage_path(), filename))

    if String.starts_with?(full_path, base_path) and File.exists?(full_path) do
      content = File.read!(full_path)
      content_type = content_type_for(filename)

      conn
      |> put_resp_content_type(content_type)
      |> send_resp(200, content)
    else
      send_resp(conn, 404, "Not found")
    end
  end

  defp content_type_for(filename) do
    case Path.extname(filename) do
      ".css" -> "text/css"
      ".js" -> "application/javascript"
      ".html" -> "text/html"
      ".ico" -> "image/x-icon"
      ".svg" -> "image/svg+xml"
      ".jpg" -> "image/jpeg"
      ".gif" -> "image/gif"
      ".png" -> "image/png"
      ".ttf" -> "font/ttf"
      ".woff" -> "font/woff"
      ".woff2" -> "font/woff2"
      _ -> "application/octet-stream"
    end
  end
end
