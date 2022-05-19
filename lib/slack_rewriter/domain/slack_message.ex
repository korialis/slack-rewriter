defmodule SlackRewriter.Domain.SlackMessage do
  @moduledoc false
  @enforce_keys [:user_id, :text, :channel, :timestamp]
  defstruct [:user_id, :text, :channel, :timestamp]

  @type t :: %__MODULE__{
          user_id: String.t(),
          text: String.t(),
          channel: String.t(),
          timestamp: String.t()
        }

  @nested_message_subtypes ["message_changed", "message_replied"]

  @spec from_event(%{}) :: {:ok, t()} | {:error, :not_rewritable_message}
  def from_event(%{
        "channel" => channel,
        "user" => user,
        "ts" => ts,
        "text" => text
      }) do
    {:ok, %__MODULE__{user_id: user, text: text, channel: channel, timestamp: ts}}
  end

  def from_event(%{
        "subtype" => subtype,
        "channel" => channel,
        "message" => %{
          "user" => user,
          "ts" => ts,
          "text" => text
        }
      })
      when subtype in @nested_message_subtypes do
    {:ok, %__MODULE__{user_id: user, text: text, channel: channel, timestamp: ts}}
  end

  def from_event(_) do
    {:error, :not_rewritable_message}
  end
end
