defmodule ELBCognitoPlug do
  @behaviour Plug
  import Plug.Conn
  import ELBCognitoPlug.JWT

  def init(opts) do
    opts
    |> Keyword.put_new(:keys_module, ELBCognitoPlug.Cognito.TeslaCachedKeys)
  end

  def call(conn, opts) do
    case {get_req_header(conn, "x-amzn-oidc-accesstoken"),
          get_req_header(conn, "x-amzn-oidc-data")} do
      {[access_token], [data]} ->
        verification_opts = Keyword.take(opts, [:keys_module, :region, :pool_id])
        {:ok, cognito_claims} = verify_cognito_jwt(access_token, verification_opts)
        {:ok, elb_claims} = verify_elb_jwt(data, verification_opts)

        conn
        |> check_has_group(cognito_claims, opts[:has_group])
        |> assign_claims(cognito_claims, elb_claims, opts[:assign_to])

      _else ->
        if Keyword.get(opts, :require_header, true) do
          deny(conn)
        else
          conn
        end
    end
  end

  defp deny(conn) do
    conn
    |> send_resp(401, "")
    |> halt()
  end

  defp check_has_group(conn, _claims, nil) do
    conn
  end

  defp check_has_group(conn, claims, group) do
    if Enum.member?(claims["cognito:groups"], group) do
      conn
    else
      deny(conn)
    end
  end

  defp assign_claims(conn, _, _, nil), do: conn

  defp assign_claims(conn, cognito_claims, elb_claims, to) do
    data = %{
      given_name: elb_claims["given_name"],
      family_name: elb_claims["family_name"],
      email: elb_claims["email"],
      sub: cognito_claims["sub"],
      username: cognito_claims["username"],
      groups: cognito_claims["cognito:groups"]
    }

    assign(conn, to, data)
  end
end
