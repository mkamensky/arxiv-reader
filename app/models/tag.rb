class Tag < ApplicationRecord
  belongs_to :user

  has_many_through :papers, :paper_tags

  validates :val, presence: true, uniqueness: { scope: :user }

  alias_method :val, :value

  def self.inertia_params(**)
    super.vdeep_merge(only: %i[color])
  end
end
