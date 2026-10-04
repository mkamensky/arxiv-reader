class AddRecommendationFeedbackAndLlmSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :llm_connections, :model, :string
    add_column :llm_connections, :thinking_level, :string

    create_table :recommendation_feedbacks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :paper, null: false, foreign_key: true
      t.string :sentiment, null: false
      t.timestamps
    end
    add_index :recommendation_feedbacks, %i[user_id paper_id], unique: true
  end
end
