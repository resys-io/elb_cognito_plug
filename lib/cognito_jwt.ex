defmodule ELBCognitoPlug.Cognito.JWT do
  def verify_jwt(jwt, keys_module, region, pool_id) do
    with {:ok, %{"kid" => key_id}} <- Joken.peek_header(jwt),
         {:ok, jwk_key} <- keys_module.get_jwk_key(key_id, region, pool_id) do
      verify_with_key(jwt, jwk_key)
    else
      _ ->
        {:error, :invalid_token}
    end
  end

  def verify_with_key(jwt, key) do
    # TODO: verify expiration, iss, token_use (==access) and client_id
    signer = Joken.Signer.create(key["alg"], key)
    Joken.verify(jwt, signer)
  end
end
