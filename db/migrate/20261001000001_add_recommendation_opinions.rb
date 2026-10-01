class AddRecommendationOpinions < ActiveRecord::Migration[8.1]
  def change
    change_table :recommendations, bulk: true do
      it.string :provider, null: false, default: 'openai'
      it.string :model
    end
    create_table :second_opinions do
      it.references :recommendation, null: false, foreign_key: true
      it.string :provider, null: false
      it.string :model, null: false
      it.decimal :score, null: false
      it.text :reason, null: false
      it.timestamps
    end
    add_index :second_opinions, %i[recommendation_id provider], unique: true
  end
end
