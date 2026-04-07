---

### Changelog

#### 0.2.1
- Refactored container definition for faster setup
- It is now possible to run multiple elahna apps on one NixOS host
- Removed pandoc as dependency

#### 0.2.0
- Content stored as flat structure, to increase compatibility with Lahna project
- Added dynamic content processing
- Inline HTML in Markdown files is now rendered correctly
- Markdown is now also rendered inside HTML-Tags
- Controllers refactored
- MD-Files are now always get rendered to HTML, even withouth explicit md-request
- Key for development environment is now automaticly generated in the nix-shell

#### 0.1.8
- Elixir rewrite of lahna.burij.de with identical features
- New main smiley
- Changelog added
- nix-files refactored
- Added deployement via nix-container
