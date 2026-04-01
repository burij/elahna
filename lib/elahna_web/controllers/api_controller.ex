defmodule ElahnaWeb.ApiController do
  use ElahnaWeb, :controller

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
