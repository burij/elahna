defmodule ElahnaWeb.HtmlController do
  use ElahnaWeb, :controller

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
end
