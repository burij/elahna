defmodule ElahnaWeb.Router do
  use ElahnaWeb, :router

  pipeline :api do
    plug(:accepts, ["json", "html"])
  end

  scope "/api", ElahnaWeb do
    pipe_through(:api)

    get("/xml/:filename", ContentController, :show_xml)
    get("/md/:filename", ContentController, :show_md)
    post("/countletters", ApiController, :countletters)
  end

  scope "/", ElahnaWeb do
    pipe_through(:api)

    get("/", HtmlController, :index)
    get("/xml/:filename", ContentController, :show_xml)
    get("/md/:filename", ContentController, :show_md)
    get("/*path", FileController, :file)
  end
end
