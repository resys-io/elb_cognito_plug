defmodule ELBCognitoPlug.Cognito.Keys do
  @callback get_jwk_key(String.t(), String.t(), String.t()) :: {:ok, term} | {:error, atom}
end
