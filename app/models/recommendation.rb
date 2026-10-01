class Recommendation < ApplicationRecord
  belongs_to :paper
  belongs_to :user
  has_many :second_opinions, dependent: :destroy

  validates :paper, uniqueness: { scope: :user }
  validates :score, presence: true
  validates :provider, inclusion: { in: LlmConnection::PROVIDERS }

  delegate :arxiv, to: :paper
end
