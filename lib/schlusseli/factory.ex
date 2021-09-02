defmodule Schlusseli.Factory do
  # without Ecto
  use ExMachina

  # https://didyouknowhomes.com/8-different-types-of-keys-in-depth-explanation/
  @key_types ["transponder", "laser-cut", "dimple", "tubular", "primary"]

  def key_factory() do
    %{
      id: sequence(:id, & &1, start_at: 1),
      serial: :os.system_time(:millisecond),
      type: sequence(:type, @key_types)
    }
  end

  def customer_factory do
    %{
      id: sequence(:id, & &1, start_at: 1),
      name: "Hans Lock Smith",
      email: sequence(:email, &"email-#{&1}@example.com")
    }
  end
end
