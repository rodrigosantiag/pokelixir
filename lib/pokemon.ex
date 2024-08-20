defmodule Pokemon do
  @moduledoc """
  This module is responsible for defining the Pokemon struct and its functions.
  """

  defstruct id: nil,
            name: nil,
            hp: nil,
            attack: nil,
            defense: nil,
            special_attack: nil,
            special_defense: nil,
            speed: nil,
            weight: nil,
            height: nil,
            types: []
end
