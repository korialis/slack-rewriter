defmodule SlackRewriter.Application.SlackRewriter do
  @moduledoc """
  SlackRewriter
  """
  alias SlackRewriter.Application.UserRegistry
  alias SlackRewriter.Bridge.Slack
  alias SlackRewriter.Domain.SlackMessage
  alias SlackRewriter.Utils.YoutrackMatcher

  @type response :: :ok | {:error, String.t()}

  @spec react_to_message(map()) :: response()
  def react_to_message(event) do
    case SlackMessage.from_event(event) do
      {:ok, message} -> do_react_to_message(message)
      {:error, _} -> :ok
    end
  end

  @spec do_react_to_message(SlackMessage.t()) :: response()
  defp do_react_to_message(message) do
    matching = YoutrackMatcher.matches_youtrack_card?(message.text)

    if matching do
      do_react_to_matching_message(message)
    else
      :ok
    end
  end

  @spec do_react_to_matching_message(SlackMessage.t()) :: response()
  defp do_react_to_matching_message(message) do
    with {:ok, user} <- UserRegistry.find(message.user_id),
         new_text <- YoutrackMatcher.normalize_youtrack_card_link(message.text),
         {:ok, _} <-
           Slack.update_message(new_text, user.user_token, message.channel, message.timestamp) do
      :ok
    else
      # think about having a function telling you if it is a user error
      {:error, user_error} when user_error in [:user_not_found, "user_not_authorized"] ->
        Slack.send_ephemeral_alert(message.user_id, message.channel)
        :ok

      error ->
        error
    end
  end
end
