# frozen_string_literal: true

class User < ApplicationRecord
  include FriendlyId
  friendly_id :arxiv, use: %i[finders]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  belongs_to :author, optional: true
  has_many_through :papers, :bookmarks
  has_many_through :recommended, :recommendations, source: :paper
  has_many_through :authors, :followships

  validates :email, presence: true, uniqueness: true
  before_save { email&.downcase! }

  def update_recommended(force: false)
    recent = recommended.maximum(:updated_at) || 1.hour.ago
    return if papers.empty? || (!force && recent < 1.day.ago)

    ranks = `python bin/buildsvm.py #{papers.map(&:arxiv).join(' ')}`.
            split("\n").to_h(&:split)
    ids = ranks.keys
    old = recommended.map(&:arxiv)
    recommendations.where(paper: { arxiv: old - ids }).destroy_all
    (ids - old).each do |id|
      paper = Paper.find_by(arxiv: id)
      next unless paper

      recommendations.create!(paper:, score: ranks[id])
    end
  end
end
