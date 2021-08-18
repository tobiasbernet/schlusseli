defmodule SchlusseliWeb.Resolvers.Key do

  alias Schlusseli.Factory

  def list_keys(_parent, _args, _resolution) do
    {:ok, Factory.generate_keys()}
  end

end
