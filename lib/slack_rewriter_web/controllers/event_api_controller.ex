defmodule SlackRewriterWeb.EventApiController do
  use SlackRewriterWeb, :controller

  alias SlackRewriter.Application.UserRegistry
  alias SlackRewriter.Bridge.Slack

  alias SlackRewriter.Application.SlackRewriter

  def event_handler(
        conn = %{body_params: %{"challenge" => challenge, "token" => _token, "type" => _type}},
        _params
      ) do
    # recall: verify slack token (better: read doc about signed secrets)
    conn
    |> put_resp_content_type("application/x-www-form-urlencoded")
    |> json(%{challenge: challenge})
  end

  def event_handler(
        conn = %{
          body_params: %{
            "event" => %{"type" => "message"} = event
          }
        },
        _params
      ) do
    spawn(fn -> SlackRewriter.react_to_message(event) end)

    # istantly respond to slack with 200, OK
    send_resp(conn, 200, "OK")
  end

  def event_handler(conn, _params) do
    send_resp(conn, 200, "OK")
  end

  def app_install_code(conn = %{params: %{"code" => code}}, _params) do
    case Slack.get_user_token(code) do
      {:ok, %{"authed_user" => %{"id" => id, "access_token" => access_token}}} ->
        UserRegistry.insert_user!(id, access_token)
        send_resp(conn, 200, "OK: user registered")

      {:error, reason} ->
        send_resp(conn, 500, "Error: #{reason}")
    end
  end

  def app_install_code(conn = %{params: %{"error" => reason}}, _params) do
    send_resp(conn, 200, "OAuth refused by user: #{reason}")
  end
end
