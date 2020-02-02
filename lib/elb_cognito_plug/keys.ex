defmodule ELBCognitoPlug.Keys do
  @callback get_cognito_jwk(String.t(), term) :: {:ok, term} | {:error, atom}
  @callback get_elb_jwk(String.t(), term) :: {:ok, term} | {:error, atom}
end
