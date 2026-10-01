class CreateRecommendationConsiderations < ActiveRecord::Migration[8.1]
  def change
    create_table :recommendation_considerations do
      it.references :user, null: false, foreign_key: true
      it.references :paper, null: false, foreign_key: true
      it.timestamps
    end
    add_index :recommendation_considerations, %i[user_id paper_id], unique: true,
      name: 'index_recommendation_considerations_on_user_and_paper'
  end
end
