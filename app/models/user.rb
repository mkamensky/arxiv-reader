# frozen_string_literal: true

class User < ApplicationRecord
  include FriendlyId

  friendly_id :email, use: %i[finders]
  has_secure_password
  has_many :sessions, dependent: :destroy

  belongs_to :author, optional: true
  has_many_through :papers, :bookmarks
  # auto recommendations, currently unused
  has_many_through :recommended, :recommendations, source: :paper
  has_many_through :authors, :followships

  validates :email, presence: true, uniqueness: true
  normalizes :email, with: ->(e) { e.strip.downcase }

  def label
    name || email
  end

  def value
    email
  end
end
