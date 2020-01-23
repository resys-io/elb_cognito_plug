defmodule MockCognitoKeys do
  @behaviour ELBCognitoPlug.Cognito.Keys

  def get_jwk_key(key, _region, _pool) do
    get_jwk_key(key)
  end

  def get_jwk_key("key_id") do
    {:ok,
     %{
       "alg" => "RS256",
       "e" => "AQAB",
       "kid" => "key_id",
       "kty" => "RSA",
       "n" =>
         "1FoWO7qzrp0yZqCiw27kUVQszR4TCpzoZ06l5sytYWIYDy35v_2SWdOY53M1OGa__LW5Wbnf42czzK3nCRtXxWFSInyYVu6vSRxhkrIC_O5vjl9UGNWK0-m9WGPUOBlNOXcp0G_0FfvUrbH60Ake_MaWuck8NegbN6lm3Hvz3-2GTs_CxGMfT43Nq0-xGRyNuKNUbDHTRxpStuXJAdn1t-bJ1P9xdiaIllfwquRcOsHRo3keRgQvPXGtokTolCMIx4SitQNXhGXgsRGBU3DHjfRhsVFB2K3DaSMRIZM2Ls_NBKzXdO1wk6ffZHAQNl3RhCc0lqcnljLYilwiwGEGB7YkoG22wDi4ixyQRkpnN361ekeqS4WVr36MKkqWn57LnNxBVs_bT8hlC9BsYK2PE5FYcxRfqBILU9M0JcFJKoLhY_j0l-0WiZn5vBbHzkYVHH7tNmAewMAzJLrw_jVQOewAL26n4EnblZciHmgkfetVZibk8Nel_ORdBzHk5RXdAEAQJD7Q2JHiSOJDMH1c_3HIKvI_XOiNoGfnT4zE2MSfeF_7we89GpS3ZPF5DJN2o6elvBomeZrf4KIsxIl0GU7XBWteLQQn3kFfBOVrnhxnzEFugjzP58kw0Ov3WQ1I0lFNkAuo5aoq9j0kW1xm88o9_MEovutUkaYiDy9s17k",
       "use" => "sig"
     }}
  end
end
