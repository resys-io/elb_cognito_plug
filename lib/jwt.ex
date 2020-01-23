defmodule ELBCognitoPlug.JWT do
  def verify_cognito_jwt(jwt, opts) do
    {:ok, keys_module} = Keyword.fetch(opts, :keys_module)

    with {:ok, %{"kid" => key_id}} <- Joken.peek_header(jwt),
         {:ok, jwk_key} <- keys_module.get_cognito_jwk(key_id, opts) do
      signer = Joken.Signer.create(jwk_key["alg"], jwk_key)
      verify_with_key(jwt, signer)
    else
      _ ->
        {:error, :invalid_token}
    end
  end

  def verify_elb_jwt(jwt, opts) do
    {:ok, keys_module} = Keyword.fetch(opts, :keys_module)

    with {:ok, %{"kid" => key_id}} <- Joken.peek_header(jwt),
         {:ok, jwk_key} <- keys_module.get_elb_jwk(key_id, opts) do
      signer = Joken.Signer.create("ES256", %{"pem" => jwk_key})
      verify_with_key(jwt, signer)
    else
      _ ->
        {:error, :invalid_token}
    end
  end

  def verify_with_key(jwt, signer) do
    # TODO: verify expiration, iss, token_use (==access) and client_id
    Joken.verify(jwt, signer)
  end
end
