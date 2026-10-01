class AddRecommendationProcessingLeaseToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :recommendation_processing_started_at, :datetime
  end
end
