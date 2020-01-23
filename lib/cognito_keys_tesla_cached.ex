defmodule ELBCognitoPlug.Cognito.TeslaCachedKeys do
  @behaviour ELBCognitoPlug.Cognito.Keys
  @ets_table __MODULE__

  def get_jwk_key(id, region, pool_id) do
    get_jwk_keys(region, pool_id)
    |> Map.get(id)
    |> case do
      nil ->
        {:error, :nonexistent_key}

      key ->
        {:ok, key}
    end
  end

  defp get_jwk_keys(region, pool_id) do
    if :ets.whereis(@ets_table) == :undefined do
      :ets.new(@ets_table, [:named_table])
    end

    case :ets.lookup(@ets_table, {region, pool_id}) do
      [{_key, value}] ->
        value

      [] ->
        keys = pull_jwk_keys_from_aws(region, pool_id)
        :ets.insert(@ets_table, {{region, pool_id}, keys})
        keys
    end
  end

  defp pull_jwk_keys_from_aws(region, pool_id) do
    Tesla.get!("https://cognito-idp.#{region}.amazonaws.com/#{pool_id}/.well-known/jwks.json")
    |> Map.get(:body)
    |> Jason.decode!()
    |> Map.get("keys")
    |> Enum.into(%{}, fn key -> {key["kid"], key} end)
  end
end
