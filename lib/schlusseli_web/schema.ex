defmodule SchlusseliWeb.Schema do
  use Absinthe.Schema

  import_types SchlusseliWeb.Schema.KeyTypes
  import_types SchlusseliWeb.Schema.CustomerTypes

  alias SchlusseliWeb.Resolvers

  query do

    @desc "Get all keys"
    field :keys, list_of(:key) do
      resolve &Resolvers.Key.list_keys/3
    end

    @desc "Get all customers"
    field :customers, list_of(:customer) do
      resolve &Resolvers.Customer.list_customers/3
    end

  end

end
