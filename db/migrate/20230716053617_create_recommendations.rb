class CreateRecommendations < ActiveRecord::Migration[7.0]
  def change
    create_table :recommendations do |t|
      t.references :paper, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true, index: true
      t.float :score, null: false, default: 1

      t.timestamps
    end
    add_index :recommendations, %i[paper_id user_id], unique: true
  end
end
