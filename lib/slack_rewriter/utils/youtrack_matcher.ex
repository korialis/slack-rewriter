defmodule SlackRewriter.Utils.YoutrackMatcher do
  @moduledoc """
  Youtrack card link matching utility
  """

  # @card_regex ~r/youtrack\/\S*\/\S*\/\S*issue=(?<card_id>\S*-\S*)/imu
  @card_regex ~r/youtrack\/\S*issue=(?<card_id>\S*-\S*)/imu

  @doc ~S"""
  iex> matches_youtrack_card?("")
  false

  iex> matches_youtrack_card?("https://prima-assicurazioni-spa.myjetbrains.com/youtrack/issue=MOTOR-1416")
  true

  iex> matches_youtrack_card?("https://prima-assicurazioni-spa.myjetbrains.com/youtrack//issue=MOTOR-1416")
  true

  iex> matches_youtrack_card?("https://prima-assicurazioni-spa.myjetbrains.com/youtrack/issue/MOTOR-1416")
  false

  iex> matches_youtrack_card?("anything/youtrack/issue=Any-any")
  true

  iex> matches_youtrack_card?("loremipsum something \r\n dummytext \r\n anything/youtrack/issue=Any-any\r\n loremipsum")
  true
  """
  @spec matches_youtrack_card?(String.t()) :: boolean()
  def matches_youtrack_card?(text) do
    Regex.match?(@card_regex, text)
  end

  @doc ~S"""
  iex> normalize_youtrack_card_link("")
  ""

  iex> normalize_youtrack_card_link("https://prima-assicurazioni-spa.myjetbrains.com/youtrack/issue=MOTOR-1416")
  "https://prima-assicurazioni-spa.myjetbrains.com/youtrack/issue/MOTOR-1416"

  iex> normalize_youtrack_card_link("https://prima-assicurazioni-spa.myjetbrains.com/youtrack//issue=MOTOR-1416")
  "https://prima-assicurazioni-spa.myjetbrains.com/youtrack/issue/MOTOR-1416"

  iex> normalize_youtrack_card_link("https://prima-assicurazioni-spa.myjetbrains.com/youtrack/issue/MOTOR-1416")
  "https://prima-assicurazioni-spa.myjetbrains.com/youtrack/issue/MOTOR-1416"

  iex> normalize_youtrack_card_link("anything/youtrack/issue=Any-any")
  "anything/youtrack/issue/Any-any"

  iex> normalize_youtrack_card_link("loremipsum something \r\n dummytext \r\n anything/youtrack/lorem/issue=Any-any\r\n loremipsum")
  "loremipsum something \r\n dummytext \r\n anything/youtrack/issue/Any-any\r\n loremipsum"

  iex> normalize_youtrack_card_link("https://prima-assicurazioni-spa.myjetbrains.com/youtrack/agiles/95-167/current?issue=MOTOR-1353|link")
  "https://prima-assicurazioni-spa.myjetbrains.com/youtrack/issue/MOTOR-1353|link"
  """
  @spec normalize_youtrack_card_link(String.t()) :: String.t()
  def normalize_youtrack_card_link(text) do
    Regex.replace(@card_regex, text, "youtrack/issue/\\1")
  end
end
