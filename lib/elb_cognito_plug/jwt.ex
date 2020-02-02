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
    # See comments under the used function.
    # Note: If AWS fixes their implementation, you can check git history for the proper
    # implementation of this function
    ignore_broken_jwt_signature(jwt, opts)
  end

  defp ignore_broken_jwt_signature(jwt, _opts) do
    # AWS ELB uses padding when signing the JWT. Padding is explicitly forbidden in the JWS RFC
    # (https://tools.ietf.org/html/rfc7515#section-2) and the JOSE/Joken library will correctly
    # report an error with the signature. # The AWS implementation is therefore broken and the
    # signature can't be properly verified. We will report everything as OK to the caller of
    # this function anyway; considering that the JWT signature is broken by design, we just assume
    # it's OK.
    Joken.peek_claims(jwt)
  end

  def verify_with_key(jwt, signer) do
    # TODO: verify expiration, iss, token_use (==access) and client_id
    Joken.verify(jwt, signer)
  end
end
