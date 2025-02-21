# MkDocs Usage

For full documentation visit [mkdocs.org](https://www.mkdocs.org).

## Commands

### Unix/Linux

* `mkdocs new [dir-name]` - Create a new project.
* `mkdocs serve` - Start the live-reloading docs server.
* `mkdocs build` - Build the documentation site.
* `mkdocs -h` - Print help message and exit.

### Docker

* `docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material` - Start the live-reloading docs server.

## Project layout

    mkdocs.yml    # The configuration file.
    docs/
        index.md  # The documentation homepage.
        ...       # Other markdown pages, images and other files.
