defmodule SchlusseliWeb.Schema.KeyTypes do
  use Absinthe.Schema.Notation

  object :key do
    field :id, :id
    field :lock, :string
    field :serial, :string
  end
end
