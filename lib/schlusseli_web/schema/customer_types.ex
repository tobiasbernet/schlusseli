defmodule SchlusseliWeb.Schema.CustomerTypes do
  use Absinthe.Schema.Notation

  object :customer do
    field :id, :id
    field :email, :string
    field :name, :string
  end
end
