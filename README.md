# Pokelixir

A simple Elixir wrapper for the [PokéAPI](https://pokeapi.co/).
Part of the Dockyard Curriculum course on Elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `pokelixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pokelixir, "~> 0.1.0"}
  ]
end
```

## Usage

### Run
```bash
iex -S mix run
```

When the service is up, the server is available on `http://localhost:4000`. You can find the available endpoints on exported collection in `postman_collection/Pokemon API.postman_collection.json`

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/pokelixir>.
