class PaperTag < ApplicationRecord
  belongs_to :paper
  belongs_to :tag

  validates :paper, uniqueness: { scope: :tag }
end
