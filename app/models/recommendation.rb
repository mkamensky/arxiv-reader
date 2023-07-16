class Recommendation < ApplicationRecord
  belongs_to :paper
  belongs_to :user

  validates :paper, uniqueness: { scope: :user }
  validates :score, presence: true

  delegate :arxiv, to: :paper
end

