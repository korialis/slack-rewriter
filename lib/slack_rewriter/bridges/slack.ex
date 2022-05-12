defmodule SlackRewriter.Bridge.Slack do
  @moduledoc """
  Slack bridge
  """

  @slack_oauth_redirect Application.compile_env!(:slack_rewriter, :slack)[:slack_oauth_redirect]
  # @slack_api_base Application.compile_env!(:slack_rewriter, :slack)[:slack_api_base]

  @slack_oauth_access Application.compile_env!(:slack_rewriter, :slack)[:slack_oauth_access]
  @slack_update_message Application.compile_env!(:slack_rewriter, :slack)[:slack_update_message]
  @slack_post_ephemeral Application.compile_env!(:slack_rewriter, :slack)[:slack_post_ephemeral]

  @client_secret Application.compile_env!(:slack_rewriter, :app)[:app_secret]
  @client_id Application.compile_env!(:slack_rewriter, :app)[:app_id]
  @bot_token Application.compile_env!(:slack_rewriter, :app)[:app_bot_token]

  @type response :: {:ok, term()} | {:error, String.t()}

  @spec oauth_redirect() :: String.t()
  def oauth_redirect, do: @slack_oauth_redirect

  @spec get_user_token(String.t()) :: response()
  def get_user_token(code) do
    @slack_oauth_access
    |> HTTPoison.post(get_oauth_token_req_body(code), [
      {"Content-type", "application/x-www-form-urlencoded"}
    ])
    |> response()
  end

  @spec update_message(String.t(), String.t(), String.t(), String.t()) :: response()
  def update_message(token, channel, timestamp, text) do
    body = get_update_message_req_body(channel, timestamp, text)

    @slack_update_message
    |> HTTPoison.post(body, [
      {"Authorization", "Bearer #{token}"},
      {"Content-type", "application/json"}
    ])
    |> response()
  end

  @spec send_ephemeral_alert(String.t(), String.t()) :: response()
  def send_ephemeral_alert(user, channel) do
    body = get_post_ephemeral_req_body(user, channel)

    @slack_post_ephemeral
    |> HTTPoison.post(body, [
      {"Authorization", "Bearer #{@bot_token}"},
      {"Content-type", "application/json"}
    ])
    |> response()
  end

  @spec get_post_ephemeral_req_body(String.t(), String.t()) :: String.t()
  defp get_post_ephemeral_req_body(user, channel) do
    Jason.encode!(%{
      user: user,
      channel: channel,
      text:
        "To automatically rewrite youtrack board carts link (the one in this message will break at the end of sprint), please install the rewriter bot @ #{@slack_oauth_redirect}"
    })
  end

  @spec get_update_message_req_body(String.t(), String.t(), String.t()) :: String.t()
  defp get_update_message_req_body(channel, timestamp, text) do
    Jason.encode!(%{
      channel: channel,
      ts: timestamp,
      text: text
    })
  end

  @spec get_oauth_token_req_body(String.t()) :: String.t()
  defp get_oauth_token_req_body(code) do
    "code=#{code}&client_id=#{@client_id}&client_secret=#{@client_secret}"
  end

  @spec response({:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}) :: response()
  defp response({:ok, %HTTPoison.Response{status_code: 200, body: body_string}}) do
    Jason.decode(body_string, keys: :atoms)
  end

  defp response({:ok, %HTTPoison.Response{status_code: code, body: body_string}}) do
    {:error, "Service returned response code #{code}: #{body_string}"}
  end

  defp response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, "HTTP error #{reason}"}
  end
end
