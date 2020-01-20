defmodule ELBPlug do
  @behaviour Plug
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    case get_req_header(conn, "x-amzn-oidc-accesstoken") do
      [data] ->
        {:ok, claims} = ELBPlug.Cognito.JWT.verify_jwt(data, opts[:region], opts[:pool_id])

        cond do
          opts[:has_group] and Enum.member?(claims["cognito:groups"], opts[:has_group]) ->
            conn

          opts[:has_group] ->
            deny(conn)

          true ->
            conn
        end

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
end
