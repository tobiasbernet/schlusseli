defmodule SchlusseliWeb.Resolvers.Customer do

  alias Schlusseli.Factory

  def list_customers(_parent, _args, %{context: %{claims: _context}}) do
    {:ok, Factory.build_list(10, :customer)}
  end

end
