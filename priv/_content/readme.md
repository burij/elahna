# Elahna

Elahna is a bare-bones web server focused on (but not limited to) developing simple htmx applications in Elixir/Phoenix. [The project website is a simple demo of this.](https://elahna.burij.de)

> **💡 Note:**
> Elahna is a rewrite of [Lahna](https://github.com/burij/lahna) in Elixir/Phoenix. While Lahna used Lua, Elahna leverages the power of Elixir and its ecosystem.

Consider Elahna particularly for the following use cases:
- exploring [htmx](https://htmx.org/) if you have little to no back-end experience
- learning the basics of web development in general
- launching websites in an extremely limited amount of time
- prototyping back-end logic

# Quick start
## NixOS 

Clone the repository and spin up the development environment:

```
git clone https://github.com/burij/elahna.git && cd elahna && nix-shell
```

Start up the webserver:

```
run
```

Visit [localhost:4000](http://localhost:4000)

## Common Linux
1. Install Elixir
2. Install dependencies: ```mix deps.get```
3. Start the server: ```mix phx.server```
4. Visit [localhost:4000](http://localhost:4000)

# Project structure

Elahna is built on Phoenix (without LiveView) and uses HTMX for interactivity.

```
lib/
├── elahna.ex                 # App definition
├── elahna/
│   └── application.ex       # Application start
└── elahna_web/
    ├── endpoint.ex          # Phoenix endpoint
    ├── router.ex            # Routes definition
    ├── file_guard.ex        # Security module
    └── controllers/
        ├── html_controller.ex      # index.html
        ├── content_controller.ex   # MD and XML files
        ├── file_controller.ex      # CSS, JS, images
        └── api_controller.ex       # Custom API extension point

priv/
└── content/
    ├── index.html           # Main HTML page
    ├── *.md                 # Markdown files
    ├── *.xml                # XML snippets for htmx
    └── assets/              # CSS, JS, images
```

# Endpoints

Elahna comes with several built-in endpoints:

- `GET /` - Serves index.html
- `GET /md/<name>` - Renders `<name>.md` as HTML
- `GET /xml/<name>` - Serves `<name>.xml`
- `GET /*path` - Serves assets (CSS, JS, images)
- `POST /api/countletters` - Returns a template with the count of letters

# Customization

1. **Static Content:** Edit `priv/content/index.html`
2. **Dynamic Content:** Add XML or MD files to `priv/content/`
3. **Routes:** Modify `lib/elahna_web/router.ex`
4. **Custom API Endpoints:** Add to `lib/elahna_web/controllers/api_controller.ex`

# Philosophy

- **Minimal by Design:** Only the essentials—no bloat, no magic.
- **Fun with Elixir:** Web development should be accessible and enjoyable.
- **Pragmatic, Not Dogmatic:** Use what works, skip what doesn't.
- **Easy to Hack:** Everything's in one place, ready to be customized.
