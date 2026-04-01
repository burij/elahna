defmodule ElahnaWeb.Router do
  use ElahnaWeb, :router

  pipeline :api do
    plug(:accepts, ["json", "html"])
  end

  scope "/", ElahnaWeb do
    pipe_through(:api)

    get("/", FileContentController, :index)
    get("/xml/:filename", FileContentController, :show_xml)
    get("/md/:filename", FileContentController, :show_md)
  end

  scope "/api", ElahnaWeb do
    pipe_through(:api)

    get("/xml/:filename", FileContentController, :show_xml)
    get("/md/:filename", FileContentController, :show_md)
    post("/countletters", FileContentController, :countletters)
  end
end
