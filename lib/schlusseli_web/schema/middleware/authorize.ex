defmodule SchlusseliWeb.Schema.Middleware.Authorize do
  @behaviour Absinthe.Middleware

  def call(resolution, scope) do
    with %{claims: %{scope: current_scopes}} <- resolution.context,
    true <- correct_scope?(current_scopes, scope) do
      resolution
    else
      _ ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "unauthorized"})
    end
  end

  defp correct_scope?(current_scopes, scope), do: String.contains?(current_scopes, scope)
end
