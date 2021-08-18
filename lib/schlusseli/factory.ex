defmodule Schlusseli.Factory do
  # without Ecto
  use ExMachina

  # https://didyouknowhomes.com/8-different-types-of-keys-in-depth-explanation/
  @key_types ["transponder", "laser-cut", "dimple", "tubular", "primary"]

  def key do
    %{
      serial: :os.system_time(:millisecond),
      type: sequence(:type, @key_types),
    }
  end

  def generate_keys do
    1..10
    |> Enum.map(fn i -> key() |> Map.put(:id, i) end)
  end
end
