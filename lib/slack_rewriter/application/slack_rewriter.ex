defmodule SlackRewriter.Application.SlackRewriter do
  @moduledoc """
  SlackRewriter
  """
  alias SlackRewriter.Application.UserRegistry
  alias SlackRewriter.Bridge.Slack
  alias SlackRewriter.Utils.YoutrackMatcher

  @type response :: {:ok, term()} | {:error, String.t()}

  # add subtype capture using constant
  # @flat_message_subtypes ["me_message", "file_share"]
  @nested_message_subtypes ["message_changed", "message_replied"]

  def react_to_message(%{
        "channel" => channel,
        "user" => user,
        "ts" => ts,
        "text" => text
      }) do
    do_react_to_message(
      user,
      channel,
      ts,
      text
    )
  end

  def react_to_message(%{
        "subtype" => subtype,
        "channel" => channel,
        "message" => %{
          "user" => user,
          "ts" => ts,
          "text" => text
        }
      })
      when subtype in @nested_message_subtypes do
    do_react_to_message(
      user,
      channel,
      ts,
      text
    )
  end

  @spec react_to_message(any()) :: response()
  def react_to_message(_event) do
    {:ok, nil}
  end

  @spec do_react_to_message(String.t(), String.t(), String.t(), String.t()) :: response()
  defp(do_react_to_message(user, channel, timestamp, text)) do
    matching = YoutrackMatcher.matches_youtrack_card?(text)

    if matching do
      do_react_to_matching_message(user, channel, timestamp, text)
    else
      {:ok, nil}
    end
  end

  @spec do_react_to_matching_message(String.t(), String.t(), String.t(), String.t()) :: response()
  defp do_react_to_matching_message(user_id, channel, timestamp, text) do
    case UserRegistry.find(user_id) do
      nil ->
        Slack.send_ephemeral_alert(user_id, channel)

      user ->
        text = YoutrackMatcher.normalize_youtrack_card_link(text)
        response = Slack.update_message(user.user_token, channel, timestamp, text)

        case response do
          {:ok, %{ok: true}} ->
            {:ok, nil}

          {:ok, %{error: "token_revoked"}} ->
            Slack.send_ephemeral_alert(user_id, channel)

          {:ok, %{ok: false, error: reason}} ->
            {:error, reason}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end
end
