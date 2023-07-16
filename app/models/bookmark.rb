class Bookmark < ApplicationRecord
  belongs_to :paper
  belongs_to :user
  validates :paper, uniqueness: { scope: :user }

  delegate :arxiv, to: :paper
end
