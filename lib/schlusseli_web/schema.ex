defmodule SchlusseliWeb.Schema do
  use Absinthe.Schema

  import_types SchlusseliWeb.Schema.KeyTypes

  alias SchlusseliWeb.Resolvers

  query do

    @desc "Get all keys"
    field :keys, list_of(:key) do
      resolve &Resolvers.Key.list_keys/3
    end

  end

end
