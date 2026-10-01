class AddLlmProviders < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :llm_provider, :string, null: false, default: 'openai'
    create_table :llm_connections do
      it.references :user, null: false, foreign_key: true
      it.string :provider, null: false
      it.text :api_key_ciphertext, null: false
      it.timestamps
    end
    add_index :llm_connections, %i[user_id provider], unique: true

    execute <<~SQL.squish
      INSERT INTO llm_connections (user_id, provider, api_key_ciphertext, created_at, updated_at)
      SELECT id, 'openai', llm_api_key_ciphertext, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM users WHERE llm_api_key_ciphertext IS NOT NULL
    SQL
  end

  def down
    execute 'UPDATE users SET llm_api_key_ciphertext = NULL'
    execute <<~SQL.squish
      UPDATE users SET llm_api_key_ciphertext = llm_connections.api_key_ciphertext
      FROM llm_connections
      WHERE llm_connections.user_id = users.id AND llm_connections.provider = 'openai'
    SQL
    drop_table :llm_connections
    remove_column :users, :llm_provider
  end
end
