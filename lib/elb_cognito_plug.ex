defmodule ELBCognitoPlug do
  @behaviour Plug
  import Plug.Conn
  import ELBCognitoPlug.Cognito.JWT

  def init(opts) do
    opts
    |> Keyword.put_new(:keys_module, ELBCognitoPlug.Cognito.TeslaCachedKeys)
  end

  def call(conn, opts) do
    case get_req_header(conn, "x-amzn-oidc-accesstoken") do
      [data] ->
        {:ok, claims} = verify_jwt(data, opts[:keys_module], opts[:region], opts[:pool_id])

        conn
        |> check_has_group(claims, opts[:has_group])
        |> assign_claims(claims, opts[:assign_to])

      [] ->
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

  defp assign_claims(conn, _claims, nil), do: conn

  defp assign_claims(conn, claims, to) do
    assign(conn, to, claims)
  end
end
