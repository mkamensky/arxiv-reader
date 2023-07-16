# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  belongs_to :author, optional: true
  has_many_through :papers, :bookmarks
  has_many_through :recommended, :recommendations, source: :paper
  has_many_through :authors, :followships

  validates :email, presence: true, uniqueness: true
  before_save { email&.downcase! }

  validate do |record|
    if record.password_digest.blank?
      record.errors.add(:password, :blank)
    end
  end

  validates :password, length: { maximum: 72 }
  validates :password, confirmation: true

  def update_recommended(force = false)
    return unless (papers.count > 0) &&
                  (force || (recommended.maximum(:updated_at) || 1.hour.ago) > 1.day.ago)

    ranks = Hash[`python bin/buildsvm.py #{papers.map(&:arxiv).join(' ')}`
            .split("\n").map { |x| x.split(' ') }]
    ids = ranks.keys
    old = recommended.map(&:arxiv)
    recommendations.where(paper: {arxiv: old - ids}).destroy_all
    (ids - old).each do |id|
      paper = Paper.find_by(arxiv: id)
      next unless paper

      recommendations.create(paper: paper, score: ranks[id])
    end
  end

end

