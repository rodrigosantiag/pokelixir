defmodule Pokelixir do
  @moduledoc """
  This module is responsible for managing Pokemons
  """

  @doc """
  Fetches a Pokemon by its name
  """
  @spec get(String.t() | integer()) :: {:ok, Pokemon.t()} | {:error, String.t()}
  def get(name_or_id) do
    build = Finch.build(:get, "https://pokeapi.co/api/v2/pokemon/#{name_or_id}")

    case Finch.request(build, MyFinch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        decoded_pokemon = Jason.decode!(body)

        {:ok, %Pokemon{
          id: decoded_pokemon["id"],
          name: decoded_pokemon["name"],
          hp: get_stats(decoded_pokemon, "hp"),
          attack: get_stats(decoded_pokemon, "attack"),
          defense: get_stats(decoded_pokemon, "defense"),
          special_attack: get_stats(decoded_pokemon, "special-attack"),
          special_defense: get_stats(decoded_pokemon, "special-defense"),
          speed: get_stats(decoded_pokemon, "speed"),
          weight: decoded_pokemon["weight"],
          height: decoded_pokemon["height"],
          types: Enum.map(decoded_pokemon["types"], fn type -> type["type"]["name"] end)
        }}

      {:ok, _response} ->
        {:ok, "Pokemon not found"}

      {:error, _reason} ->
        {:error, "Pokemon not found"}
    end
  end

  @doc """
  Fetches all Pokemons limited by the limit parameter
  """
  @spec all(integer(), integer()) :: [Pokemon.t()]
  def all(limit \\ 20, offset \\ 0) do
    build = Finch.build(:get, "https://pokeapi.co/api/v2/pokemon?limit=#{limit}&offset=#{offset}")

    case Finch.request(build, MyFinch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        decoded_body = Jason.decode!(body)

        decoded_body["results"]
        |> Enum.map_reduce([], fn pokemon, acc ->
          pokemon_id = String.split(pokemon["url"], "/", trim: true) |> List.last()
          {:ok, pokemon} = get(pokemon_id)
          {pokemon_id, acc ++ [pokemon]}
        end)
        |> elem(1)

      {:error, _reason} ->
        {:error, "An error has occurred"}
    end
  end

  @doc """
  Fetches all Pokemons asynchronously
  """
  @spec async_all() :: [Pokemon.t()]
  def async_all() do
    case count() do
      {:error, _reason} ->
        {:error, "An error has occurred"}

      count ->
        limit = 100
        offset = 0

        total_pages = div(count, limit)

        Task.async_stream(0..total_pages, fn page ->
          all(limit, offset + (page * limit))
        end)
        |> Enum.map_reduce([], fn {:ok, pokemons}, acc -> {pokemons, acc ++ pokemons} end)
      |> elem(1)
    end
  end

  @spec count() :: integer() | {:error, String.t()}
  defp count() do
    build = Finch.build(:get, "https://pokeapi.co/api/v2/pokemon")

    case Finch.request(build, MyFinch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        decoded_body = Jason.decode!(body)
        decoded_body["count"]

      {:error, _reason} ->
        {:error, "An error has occurred"}
    end
  end

  @spec get_stats(map(), String.t()) :: integer() | nil
  defp get_stats(decoded_pokemon, stat) do
    decoded_pokemon["stats"]
    |> Enum.find_value(fn current_stat ->
      if current_stat["stat"]["name"] == stat, do: current_stat["base_stat"]
    end)
  end
end
