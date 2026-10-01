class AddApiTokenDigestToUsers < ActiveRecord::Migration[8.1]
  def change
    # Personal token for AI agents (MCP); only its SHA-256 is stored.
    add_column :users, :api_token_digest, :string
    add_index :users, :api_token_digest, unique: true
  end
end
