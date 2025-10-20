class HiddenPaper < ApplicationRecord
  belongs_to :user
  belongs_to :paper

  validates :paper, uniqueness: { scope: :user }
end
