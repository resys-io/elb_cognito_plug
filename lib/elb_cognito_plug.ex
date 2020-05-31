defmodule ELBCognitoPlug do
  @behaviour Plug
  import Plug.Conn
  import ELBCognitoPlug.JWT

  def init(opts) do
    opts
    |> Keyword.put_new(:keys_module, ELBCognitoPlug.TeslaCachedKeys)
  end

  def call(conn, opts) do
    case {get_req_header(conn, "x-amzn-oidc-accesstoken"),
          get_req_header(conn, "x-amzn-oidc-data")} do
      {[access_token], [data]} ->
        opts = build_runtime_conf(opts)
        {:ok, cognito_claims} = verify_cognito_jwt(access_token, opts)
        {:ok, elb_claims} = verify_elb_jwt(data, opts)

        conn
        |> check_has_group(cognito_claims, opts)
        |> assign_claims(cognito_claims, elb_claims, opts[:assign_to])

      _else ->
        if Keyword.get(opts, :require_header, true) do
          deny(:missing_headers, conn, opts)
        else
          conn
        end
    end
  end

  defp build_runtime_conf(opts) do
    opts = Application.get_all_env(:elb_cognito_plug) ++ opts
    [region, _] = opts[:cognito_pool_id] |> String.split("_")
    Keyword.put(opts, :cognito_region, region)
  end

  defp deny(reason, conn, opts) do
    if handle_error = opts[:handle_error] do
      handle_error.(reason, conn, opts)
    else
      conn
      |> send_resp(401, "")
      |> halt()
    end
  end

  defp check_has_group(conn, claims, opts) do
    if group = opts[:has_group] do
      if Enum.member?(claims["cognito:groups"], group) do
        conn
      else
        deny(:missing_group, conn, opts)
      end
    else
      conn
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
      groups: cognito_claims["cognito:groups"],
      exp: cognito_claims["exp"]
    }

    assign(conn, to, data)
  end
end
