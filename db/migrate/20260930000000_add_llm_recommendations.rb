class AddLlmRecommendations < ActiveRecord::Migration[8.1]
  def change
    change_table :users, bulk: true do
      it.string :llm_mode, null: false, default: 'anonymous'
      it.text :llm_api_key_ciphertext
    end
    add_column :recommendations, :reason, :text
  end
end
