defmodule SlackRewriter.Support.EncryptedBinary do
  @moduledoc false
  use Cloak.Ecto.Binary, vault: SlackRewriter.Support.Vault
end
