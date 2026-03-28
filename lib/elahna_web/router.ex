defmodule ElahnaWeb.Router do
  use ElahnaWeb, :router

  pipeline :api do
    plug :accepts, ["json", "html"]
  end

  scope "/", ElahnaWeb do
    pipe_through :api

    get "/", FileContentController, :index
    get "/demo", FileContentController, :demo
    get "/xml/demo", FileContentController, :demo
    get "/md/:filename", FileContentController, :show_md
    get "/readme", FileContentController, :readme
  end

  scope "/api", ElahnaWeb do
    pipe_through :api

    get "/xml/:filename", FileContentController, :show_xml
    get "/md/:filename", FileContentController, :show_md
    get "/index/:type", FileContentController, :index_files
    post "/countletters", FileContentController, :countletters
  end
end
