defmodule Pokelixir.Router do
  use Plug.Router

  plug(Plug.Logger)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/async-all" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(Pokelixir.async_all()))
  end

  get "/pokemon/:name_or_id" do
    name_or_id = conn.params["name_or_id"]

    case Pokelixir.get(name_or_id) do
      {:ok, %Pokemon{} = pokemon} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(pokemon))

      {:ok, "Pokemon not found"} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, "Pokemon not found")

      {:error, reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(404, reason)
    end
  end

  get "/all" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(Pokelixir.all(conn.params["limit"])))
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
