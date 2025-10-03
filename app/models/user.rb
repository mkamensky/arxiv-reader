# frozen_string_literal: true

class User < ApplicationRecord
  #include FriendlyId

  #friendly_id :value, use: %i[finders]
  has_secure_password
  has_many :sessions, dependent: :destroy

  belongs_to :author, optional: true
  has_many_through :bpapers, :bookmarks, source: :paper
  # auto recommendations, currently unused
  has_many_through :recommended, :recommendations, source: :paper
  has_many_through :fauthors, :followships, source: :author

  belongs_to :subject, optional: true # default subject
  has_many_through :categories, :usercats

  validates :email, presence: true, uniqueness: true
  normalizes :email, with: -> { it.strip.downcase }

  def self.inertia_params(**)
    super.vdeep_merge(only: %i[avatar])
  end

  def label
    name || email
  end

  def value
    email
  end
end
