defmodule ElahnaWeb.FileContentController do
  use ElahnaWeb, :controller
  alias ElahnaWeb.FileGuard

  defp storage_path do
    Application.get_env(:elahna, :content_storage) ||
      Application.app_dir(:elahna, "priv/content")
  end

  def index(conn, _params) do
    html_path = Application.app_dir(:elahna, "priv/static/index.html")
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

  def show_xml(conn, %{"filename" => filename}) do
    base_dir = Path.join(storage_path(), "xml")

    case FileGuard.safe_path(base_dir, filename, "xml") do
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
    base_dir = Path.join(storage_path(), "md")

    case FileGuard.safe_path(base_dir, filename, "md") do
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

  def index_files(conn, %{"type" => type}) do
    folder = Path.join(storage_path(), type)

    case File.ls(folder) do
      {:ok, files} ->
        slugs =
          files
          |> Enum.filter(&String.ends_with?(&1, ".#{type}"))
          |> Enum.map(&String.replace(&1, ".#{type}", ""))
          |> Enum.sort()

        json(conn, %{slugs: slugs, type: type})

      {:error, _} ->
        json(conn, %{error: "Folder not found"})
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

  def demo(conn, _params) do
    xml_path = Path.join([storage_path(), "xml", "demo.xml"])

    if File.exists?(xml_path) do
      content = File.read!(xml_path)

      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, content)
    else
      send_resp(conn, 404, "Demo file not found")
    end
  end

  def readme(conn, _params) do
    md_path = Path.join([storage_path(), "md", "readme.md"])

    if File.exists?(md_path) do
      content = File.read!(md_path)
      html = Earmark.as_html!(content)

      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, html)
    else
      send_resp(conn, 404, "README file not found")
    end
  end
end
