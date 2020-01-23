defmodule ELBCognitoPlug.Cognito.JWTTest do
  use ExUnit.Case
  import ELBCognitoPlug.Cognito.JWT
  doctest ELBCognitoPlug.Cognito.JWT

  test "verify_with_key/2 returns claims if signature is correct" do
    jwt =
      "eyJraWQiOiJrZXlfaWQiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI1ZWIzOTNmNC1kZTI5LTQzODYtYjUyMC00OWZkMWRlMWIxMjIiLCJjb2duaXRvOmdyb3VwcyI6WyJhZG1pbiIsIm90aGVyLWdyb3VwIl0sImV2ZW50X2lkIjoiNGY2MGI2ZDctMTkyMy00NGYwLWE5ZDEtMjU2YjA5NDUxYzIzIiwidG9rZW5fdXNlIjoiYWNjZXNzIiwic2NvcGUiOiJvcGVuaWQiLCJhdXRoX3RpbWUiOjE1NzY0NTk5NTksImlzcyI6Imh0dHBzOi8vY29nbml0by1pZHAucmVnaW9uLmFtYXpvbmF3cy5jb20vcG9vbCIsImV4cCI6MTU3NjQ2MzU1OSwiaWF0IjoxNTc2NDU5OTU5LCJqdGkiOiI2YWU5MTIzYS05NmZhLTQ0MjItYWFjOS04Mjk0ZWQ4NjBlMzMiLCJjbGllbnRfaWQiOiJwaWNxc3hNU1RaVlhYOHJubzRCbjB6SFhqcCIsInVzZXJuYW1lIjoiNWViMzkzZjQtZGUyOS00Mzg2LWI1MjAtNDlmZDFkZTFiMTIyIn0.bK2De82h7NCSYur5UcTNCqTOGZYt8Xw043c45j716QCND2kcbA7JHk71JNu5jxZbv6DUqmZYY8iauSKxZJYtn7ETHa0WI7x4uWv8qblUWygj-DYR3xf8aWj_QelXo9NXlvMCVXcbG-xn_Wu8rSbNwlIiod5F2gDA3xubhUOKUhZ51RGqidTo6l-r-slXKakmpvDVyWcwsUeeN7JXogDDa1-RA_wx0pGTVronmGpW_NV-fCRXsA35sGXgJ2Yj8B1wRPiwnfhN66BCr6UH8UHdut0v3K-MJMIEqh1MKGNfcTO7-K4tIavrbozcSgpBxfWbYS4odI_HZzCrruJFg6wfKGav5-h97pVdukuGEEolqj2-aNZ9PrdF4No7pjFxsa4str4-mxolwr0UxvTs58cn7bjKpP77yCQuI3FHoHb_V5NaFF_BUG6Q-JMh7tIoXjuA69_keZjBbmew80IU3jKDYa--wqHvrDs-hQqSe0LULW4ao-SGXceivxn1_YhxqmrpdN1HLIDcPuNJ8GTYJ6q1u2Fu45R7xK7deRlYDDiDrWCQhizslv8UvNYOBFlnlUvSt5zWNJdcUewR2OXC3UqqEf6GWj69p4Jz2yJOG2vKi5uhs9Pexcjm-3sWAM2mEQO5mNT8gWCSl7l2cA6lT07tb6fjW9202upkYmdC4wFRtzM"

    {:ok, key} = MockCognitoKeys.get_jwk_key("key_id")

    expected_claims = %{
      "auth_time" => 1_576_459_959,
      "client_id" => "picqsxMSTZVXX8rno4Bn0zHXjp",
      "cognito:groups" => ["admin", "other-group"],
      "event_id" => "4f60b6d7-1923-44f0-a9d1-256b09451c23",
      "exp" => 1_576_463_559,
      "iat" => 1_576_459_959,
      "iss" => "https://cognito-idp.region.amazonaws.com/pool",
      "jti" => "6ae9123a-96fa-4422-aac9-8294ed860e33",
      "scope" => "openid",
      "sub" => "5eb393f4-de29-4386-b520-49fd1de1b122",
      "token_use" => "access",
      "username" => "5eb393f4-de29-4386-b520-49fd1de1b122"
    }

    assert {:ok, ^expected_claims} = verify_with_key(jwt, key)
  end

  test "verify_with_key/2 returns error if key is incorrect" do
    jwt =
      "eyJraWQiOiJrZXlfaWQiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI1ZWIzOTNmNC1kZTI5LTQzODYtYjUyMC00OWZkMWRlMWIxMjIiLCJjb2duaXRvOmdyb3VwcyI6WyJhZG1pbiIsIm90aGVyLWdyb3VwIiwiZWxzZSJdLCJldmVudF9pZCI6IjRmNjBiNmQ3LTE5MjMtNDRmMC1hOWQxLTI1NmIwOTQ1MWMyMyIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoib3BlbmlkIiwiYXV0aF90aW1lIjoxNTc2NDU5OTU5LCJpc3MiOiJodHRwczovL2NvZ25pdG8taWRwLnJlZ2lvbi5hbWF6b25hd3MuY29tL3Bvb2wiLCJleHAiOjE1NzY0NjM1NTksImlhdCI6MTU3NjQ1OTk1OSwianRpIjoiNmFlOTEyM2EtOTZmYS00NDIyLWFhYzktODI5NGVkODYwZTMzIiwiY2xpZW50X2lkIjoicGljcXN4TVNUWlZYWDhybm80Qm4wekhYanAiLCJ1c2VybmFtZSI6IjVlYjM5M2Y0LWRlMjktNDM4Ni1iNTIwLTQ5ZmQxZGUxYjEyMiJ9.liJ3so577ZjssAqlgfunBDkdKikTHgwbSDiGROQHlDt6IEGQlQj0LMk2HpvRspnYwTWKuMw1Zpn_pUCKTkgyH43YePZW-b98M4datYCsYla-QR-Dh7Bh0CTKkcLvBClNVc3T3L6soY-fa6UGHXjRM1iROJAdBQ2VfQe5CU8qhjDcd9ocyynWmMb4CwHxr9crEvGdM3rgLPdYQLLTl342_jBq2LfZn3zGK9VWVQ-yx5Brr5kjtAFJADQ6vT0Va-dfU1uzR1bwVHMuyDmiDhcj-Jxy6GagAXGSYIKQxALGTso_-E07nyx6n37l5f1Zo0_pCvphBifvUFRWtyqrVSkzkQ"

    {:ok, key} = MockCognitoKeys.get_jwk_key("key_id")

    assert {:error, :signature_error} = verify_with_key(jwt, key)
  end

  test "verify_jwt/4 pulls key from key module and verifies the JWT" do
    jwt =
      "eyJraWQiOiJrZXlfaWQiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI1ZWIzOTNmNC1kZTI5LTQzODYtYjUyMC00OWZkMWRlMWIxMjIiLCJjb2duaXRvOmdyb3VwcyI6WyJhZG1pbiIsIm90aGVyLWdyb3VwIl0sImV2ZW50X2lkIjoiNGY2MGI2ZDctMTkyMy00NGYwLWE5ZDEtMjU2YjA5NDUxYzIzIiwidG9rZW5fdXNlIjoiYWNjZXNzIiwic2NvcGUiOiJvcGVuaWQiLCJhdXRoX3RpbWUiOjE1NzY0NTk5NTksImlzcyI6Imh0dHBzOi8vY29nbml0by1pZHAucmVnaW9uLmFtYXpvbmF3cy5jb20vcG9vbCIsImV4cCI6MTU3NjQ2MzU1OSwiaWF0IjoxNTc2NDU5OTU5LCJqdGkiOiI2YWU5MTIzYS05NmZhLTQ0MjItYWFjOS04Mjk0ZWQ4NjBlMzMiLCJjbGllbnRfaWQiOiJwaWNxc3hNU1RaVlhYOHJubzRCbjB6SFhqcCIsInVzZXJuYW1lIjoiNWViMzkzZjQtZGUyOS00Mzg2LWI1MjAtNDlmZDFkZTFiMTIyIn0.bK2De82h7NCSYur5UcTNCqTOGZYt8Xw043c45j716QCND2kcbA7JHk71JNu5jxZbv6DUqmZYY8iauSKxZJYtn7ETHa0WI7x4uWv8qblUWygj-DYR3xf8aWj_QelXo9NXlvMCVXcbG-xn_Wu8rSbNwlIiod5F2gDA3xubhUOKUhZ51RGqidTo6l-r-slXKakmpvDVyWcwsUeeN7JXogDDa1-RA_wx0pGTVronmGpW_NV-fCRXsA35sGXgJ2Yj8B1wRPiwnfhN66BCr6UH8UHdut0v3K-MJMIEqh1MKGNfcTO7-K4tIavrbozcSgpBxfWbYS4odI_HZzCrruJFg6wfKGav5-h97pVdukuGEEolqj2-aNZ9PrdF4No7pjFxsa4str4-mxolwr0UxvTs58cn7bjKpP77yCQuI3FHoHb_V5NaFF_BUG6Q-JMh7tIoXjuA69_keZjBbmew80IU3jKDYa--wqHvrDs-hQqSe0LULW4ao-SGXceivxn1_YhxqmrpdN1HLIDcPuNJ8GTYJ6q1u2Fu45R7xK7deRlYDDiDrWCQhizslv8UvNYOBFlnlUvSt5zWNJdcUewR2OXC3UqqEf6GWj69p4Jz2yJOG2vKi5uhs9Pexcjm-3sWAM2mEQO5mNT8gWCSl7l2cA6lT07tb6fjW9202upkYmdC4wFRtzM"

    assert {:ok, _claims} = verify_jwt(jwt, MockCognitoKeys, "region", "pool_id")
  end
end
