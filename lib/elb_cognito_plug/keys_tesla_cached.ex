defmodule ELBCognitoPlug.TeslaCachedKeys do
  use GenServer
  @behaviour ELBCognitoPlug.Keys

  @cognito_table :cognito_jwk_keys
  @elb_table :elb_jwk_keys

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [@cognito_table, @elb_table], opts)
  end

  # GenServer
  def init(tables) do
    for table <- tables do
      :ets.new(table, [:named_table, :public])
    end

    {:ok, nil}
  end

  # Public
  def get_cognito_jwk(id, opts) do
    get_cognito_keys(opts[:cognito_region], opts[:cognito_pool_id])
    |> Map.get(id)
    |> case do
      nil ->
        {:error, :nonexistent_key}

      key ->
        {:ok, key}
    end
  end

  def get_elb_jwk(id, opts) do
    {:ok, region} = Keyword.fetch(opts, :cognito_region)

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
