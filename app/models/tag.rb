class Tag < ApplicationRecord
  include FriendlyId

  friendly_id :val

  belongs_to :user

  has_many_through :papers, :paper_tags

  validates :val, presence: true, uniqueness: { scope: :user }

  def self.inertia_params(**)
    super.vdeep_merge(only: %i[color])
  end

  def value
    val
  end

  def label
    super.presence || val&.camelcase
  end
end
