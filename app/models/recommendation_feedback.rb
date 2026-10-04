class RecommendationFeedback < ApplicationRecord
  VALUES = %w[positive negative].freeze
  public_constant :VALUES

  belongs_to :user
  belongs_to :paper

  validates :paper, uniqueness: { scope: :user }
  validates :sentiment, inclusion: { in: VALUES }
end
