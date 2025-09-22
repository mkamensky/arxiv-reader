# frozen_string_literal: true

class User < ApplicationRecord
  include FriendlyId

  friendly_id :arxiv, use: %i[finders]

  belongs_to :author, optional: true
  has_many_through :papers, :bookmarks
  # auto recommendations, currently unused
  has_many_through :recommended, :recommendations, source: :paper
  has_many_through :authors, :followships

  validates :email, presence: true, uniqueness: true
  before_save { email&.downcase! }
end
