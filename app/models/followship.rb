class Followship < ApplicationRecord
  belongs_to :author
  belongs_to :user

  validates :author, uniqueness: { scope: :user }

  # papers by the author bookmarked by the user
  def papers
    author.papers.merge(user.bpapers)
  end
end
