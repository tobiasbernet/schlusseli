defmodule SchlusseliWeb.Resolvers.Key do

  alias Schlusseli.Factory

  def list_keys(_parent, _args, _resolution) do
    {:ok, Factory.build_list(10, :key)}
  end

end
