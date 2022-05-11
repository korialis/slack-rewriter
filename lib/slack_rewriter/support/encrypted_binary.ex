defmodule SlackRewriter.Support.EncryptedBinary do
  use Cloak.Ecto.Binary, vault: SlackRewriter.Support.Vault
end
