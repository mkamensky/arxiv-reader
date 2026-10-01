class SecondOpinion < ApplicationRecord
  belongs_to :recommendation

  validates :provider, inclusion: { in: LlmConnection::PROVIDERS },
                       uniqueness: { scope: :recommendation_id }
  validates :model, :reason, presence: true
  validates :score, numericality: { in: 0..100 }
end
