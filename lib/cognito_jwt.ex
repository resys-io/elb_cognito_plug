defmodule ELBPlug.Cognito.JWT do
  @ets_table __MODULE__

  def verify_jwt(jwt, region, pool_id) do
    with {:ok, %{"kid" => key_id, "alg" => alg}} <- Joken.peek_header(jwt),
         {:ok, jwk_key} <- get_jwk_key(key_id, region, pool_id),
         signer <- Joken.Signer.create(alg, jwk_key),
         {:ok, claims} <- Joken.verify(jwt, signer) do
      # TODO: verify expiration, iss, token_use (==access) and client_id
      {:ok, claims}
    else
      _ ->
        {:error, :invalid_token}
    end
  end

  defp get_jwk_key(id, region, pool_id) do
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
