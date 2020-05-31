defmodule ELBCognitoPlugTest do
  use ExUnit.Case
  use Plug.Test
  doctest ELBCognitoPlug

  @cognito_jwt "eyJraWQiOiJrZXlfaWQiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI1ZWIzOTNmNC1kZTI5LTQzODYtYjUyMC00OWZkMWRlMWIxMjIiLCJjb2duaXRvOmdyb3VwcyI6WyJhZG1pbiIsIm90aGVyLWdyb3VwIl0sImV2ZW50X2lkIjoiNGY2MGI2ZDctMTkyMy00NGYwLWE5ZDEtMjU2YjA5NDUxYzIzIiwidG9rZW5fdXNlIjoiYWNjZXNzIiwic2NvcGUiOiJvcGVuaWQiLCJhdXRoX3RpbWUiOjE1NzY0NTk5NTksImlzcyI6Imh0dHBzOi8vY29nbml0by1pZHAucmVnaW9uLmFtYXpvbmF3cy5jb20vcG9vbCIsImV4cCI6MTU3NjQ2MzU1OSwiaWF0IjoxNTc2NDU5OTU5LCJqdGkiOiI2YWU5MTIzYS05NmZhLTQ0MjItYWFjOS04Mjk0ZWQ4NjBlMzMiLCJjbGllbnRfaWQiOiJwaWNxc3hNU1RaVlhYOHJubzRCbjB6SFhqcCIsInVzZXJuYW1lIjoiNWViMzkzZjQtZGUyOS00Mzg2LWI1MjAtNDlmZDFkZTFiMTIyIn0.bK2De82h7NCSYur5UcTNCqTOGZYt8Xw043c45j716QCND2kcbA7JHk71JNu5jxZbv6DUqmZYY8iauSKxZJYtn7ETHa0WI7x4uWv8qblUWygj-DYR3xf8aWj_QelXo9NXlvMCVXcbG-xn_Wu8rSbNwlIiod5F2gDA3xubhUOKUhZ51RGqidTo6l-r-slXKakmpvDVyWcwsUeeN7JXogDDa1-RA_wx0pGTVronmGpW_NV-fCRXsA35sGXgJ2Yj8B1wRPiwnfhN66BCr6UH8UHdut0v3K-MJMIEqh1MKGNfcTO7-K4tIavrbozcSgpBxfWbYS4odI_HZzCrruJFg6wfKGav5-h97pVdukuGEEolqj2-aNZ9PrdF4No7pjFxsa4str4-mxolwr0UxvTs58cn7bjKpP77yCQuI3FHoHb_V5NaFF_BUG6Q-JMh7tIoXjuA69_keZjBbmew80IU3jKDYa--wqHvrDs-hQqSe0LULW4ao-SGXceivxn1_YhxqmrpdN1HLIDcPuNJ8GTYJ6q1u2Fu45R7xK7deRlYDDiDrWCQhizslv8UvNYOBFlnlUvSt5zWNJdcUewR2OXC3UqqEf6GWj69p4Jz2yJOG2vKi5uhs9Pexcjm-3sWAM2mEQO5mNT8gWCSl7l2cA6lT07tb6fjW9202upkYmdC4wFRtzM"
  @elb_jwt "eyJ0eXAiOiJKV1QiLCJraWQiOiI5YjRiNTZjZC0zYTU0LTRkMWYtYmY3OC1jZmY2YWZjOTcxNWYiLCJhbGciOiJFUzI1NiIsImlzcyI6Imh0dHBzOi8vY29nbml0by1pZHAucmVnaW9uLmFtYXpvbmF3cy5jb20vcG9vbCIsImNsaWVudCI6InB0UzN5YlllbHYzQzdYVjhpaGpONDNOZEpiIiwic2lnbmVyIjoibG9hZGJhbGFuY2VyIiwiZXhwIjoxNTc2NDYwMTIxfQ.eyJlbWFpbCI6InVzZXJAZXhhbXBsZS5jb20iLCJlbWFpbF92ZXJpZmllZCI6IlRydWUiLCJmYW1pbHlfbmFtZSI6IlVzZXIiLCJnaXZlbl9uYW1lIjoiU29tZSIsInN1YiI6ImY0Yjg5OGNhLTdkYmMtNDdiMy05NGY4LWFkYzIxYzUyNDQxYyIsImV4cCI6MTU3NjQ2MDEyMSwiaXNzIjoiaHR0cHM6Ly9jb2duaXRvLWlkcC5yZWdpb24uYW1hem9uYXdzLmNvbS9wb29sIn0.KRXk2vfWreeDEb2xJJLkcQkbjb7YoEv9DMcmGZvkLDYrbtKaDNvwEjUdZ4HcV7bCYNXaFqQRzQ56sj8P0gDLHQ"

  defp call(opts \\ []) do
    {jwts, opts} = Keyword.pop(opts, :jwts)

    opts =
      opts
      |> Keyword.put(:cognito_region, "region")
      |> Keyword.put(:cognito_pool_id, "pool_id")
      |> Keyword.put(:keys_module, MockCognitoKeys)

    conn(:get, "/")
    |> resp(200, "")
    |> apply_jwts(jwts)
    |> ELBCognitoPlug.call(opts)
  end

  defp apply_jwts(conn, {cognito_jwt, elb_jwt}) do
    conn
    |> put_req_header("x-amzn-oidc-accesstoken", cognito_jwt)
    |> put_req_header("x-amzn-oidc-data", elb_jwt)
  end

  defp apply_jwts(conn, _), do: conn

  test "denies if `require_header` is true, but no header provided" do
    conn = call(require_header: true)
    assert conn.status == 401
  end

  test "allows if `require_header` is false and no header provided" do
    conn = call(require_header: false)
    assert conn.status == 200
  end

  test "denies if `require_header` not set and no header provided" do
    conn = call()
    assert conn.status == 401
  end

  test "allows if `has_group` provided, but `require_header` is false and no header was provided" do
    conn = call(require_header: false, has_group: "superuser")
    assert conn.status == 200
  end

  test "denies if `has_group` provided, but no such group in jwt" do
    conn = call(require_header: true, has_group: "superuser", jwts: {@cognito_jwt, @elb_jwt})
    assert conn.status == 401
  end

  test "allows if `has_group` provided and group is in jwt" do
    conn = call(require_header: true, has_group: "admin", jwts: {@cognito_jwt, @elb_jwt})
    assert conn.status == 200
  end

  test "allows if `has_group` not provided" do
    conn = call(require_header: true, jwts: {@cognito_jwt, @elb_jwt})
    assert conn.status == 200
  end

  test "does not assign if `assign_to` is not provided" do
    conn = call(require_header: true, jwts: {@cognito_jwt, @elb_jwt})
    assert conn.assigns == %{}
  end

  test "assigns if `assign_to` provided" do
    conn = call(require_header: true, assign_to: :user_claims, jwts: {@cognito_jwt, @elb_jwt})
    assert conn.status == 200
    assert conn.assigns.user_claims != nil
  end

  test "assigns correct data" do
    conn = call(require_header: true, assign_to: :user_claims, jwts: {@cognito_jwt, @elb_jwt})

    assert conn.assigns.user_claims == %{
             given_name: "Some",
             family_name: "User",
             email: "user@example.com",
             sub: "5eb393f4-de29-4386-b520-49fd1de1b122",
             username: "5eb393f4-de29-4386-b520-49fd1de1b122",
             groups: ["admin", "other-group"],
             exp: 1_576_463_559
           }
  end

  test "allows custom response if `handle_error` provided" do
    conn =
      call(
        require_header: true,
        handle_error: fn reason, conn, _opts ->
          assert reason == :missing_headers
          send_resp(conn, 500, "test")
        end
      )

    assert conn.status == 500
    assert conn.resp_body == "test"
  end

  test "provides `:missing_group` as reason to `handle_error` if `has_group` provided, but no such group in jwt" do
    conn =
      call(
        require_header: true,
        has_group: "superuser",
        jwts: {@cognito_jwt, @elb_jwt},
        handle_error: fn reason, conn, _opts ->
          assert reason == :missing_group
          send_resp(conn, 401, "")
        end
      )

    assert conn.status == 401
  end
end
