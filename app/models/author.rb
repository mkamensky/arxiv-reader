# frozen_string_literal: true

class Author < ApplicationRecord
  include FriendlyId

  friendly_id :arxiv

  has_many_through :papers, :authorships
  has_many :categories, through: :papers
  has_many :subjects, through: :categories
  has_many_through :users, :followships

  validates :name, presence: true
  validates :arxiv, uniqueness: true

  def label
    name
  end

  scope :in_category, ->(cat) {
    joins(papers: :category).distinct.where(
      papers: { categories: { arxiv: cat } },
    )
  }

  scope :in_subject, ->(subj) {
    joins(papers: { category: :subject }).distinct.where(
      papers: { categories: { subjects: { arxiv: subj } } },
    )
  }

  before_validation :update_arxiv

  def arxiv_base
    @arxiv_base ||= self.class.arxiv_base(name)
  end

  class << self
    def arxiv_base(name)
      parts = name.split
      parts.reduce(parts.pop) { |res, item| "#{res}_#{item.first}" }.parameterize
    end
  end

  protected

  def update_arxiv
    return if arxiv.present?

    nn = 0
    loop do
      nn += 1
      self.arxiv = "#{arxiv_base}_#{nn}_X"
      break unless self.class.find_by(arxiv:)
    end
  end
end
