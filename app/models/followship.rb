class Followship < ApplicationRecord
  belongs_to :author
  belongs_to :user

  validates :author, uniqueness: { scope: :user }
end
