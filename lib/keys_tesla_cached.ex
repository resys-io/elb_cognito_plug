defmodule ELBCognitoPlug.TeslaCachedKeys do
  @behaviour ELBCognitoPlug.Keys

  @cognito_table :cognito_jwk_keys
  @elb_table :elb_jwk_keys

  def get_cognito_jwk(id, opts) do
    [{:region, region}, {:pool_id, pool_id}] = Keyword.take(opts, [:region, :pool_id])

    get_cognito_keys(region, pool_id)
    |> Map.get(id)
    |> case do
      nil ->
        {:error, :nonexistent_key}

      key ->
        {:ok, key}
    end
  end

  def get_elb_jwk(id, opts) do
    {:ok, region} = Keyword.fetch(opts, :region)

    key =
      get_or_cache(@elb_table, {region, id}, fn ->
        fetch_elb_key(region, id)
      end)

    {:ok, key}
  end

  defp get_cognito_keys(region, pool_id) do
    get_or_cache(@cognito_table, {region, pool_id}, fn ->
      fetch_cognito_keys(region, pool_id)
    end)
  end

  defp get_or_cache(table, key, fun) do
    if :ets.whereis(table) == :undefined do
      :ets.new(table, [:named_table])
    end

    case :ets.lookup(table, key) do
      [{_key, value}] ->
        value

      [] ->
        keys = fun.()
        :ets.insert(table, {key, keys})
        keys
    end
  end

  defp fetch_cognito_keys(region, pool_id) do
    Tesla.get!("https://cognito-idp.#{region}.amazonaws.com/#{pool_id}/.well-known/jwks.json")
    |> Map.get(:body)
    |> Jason.decode!()
    |> Map.get("keys")
    |> Enum.into(%{}, fn key -> {key["kid"], key} end)
  end

  defp fetch_elb_key(region, key_id) do
    Tesla.get!("https://public-keys.auth.elb.#{region}.amazonaws.com/#{key_id}")
    |> Map.get(:body)
  end
end
