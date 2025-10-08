# frozen_string_literal: true

class Author < ApplicationRecord
  include FriendlyId

  friendly_id :arxiv

  include PgSearch::Model

  multisearchable

  pg_search_scope :search_all,
                  against: { name: 'A', name_variants: 'B' },
                  using: {
                    tsearch: {
                      dictionary: 'english',
                      tsvector_column: 'searchable',
                    },
                  }

  has_many_through :papers, :authorships
  has_many :categories, through: :papers
  has_many :subjects, through: :categories
  has_many_through :users, :followships

  validates :name, presence: true
  validates :arxiv, uniqueness: true
  validates :name_variants, presence: true

  def label
    name
  end

  scope :in_category, -> {
    joins(papers: :category).distinct.where(
      papers: { categories: { arxiv: it } },
    )
  }

  scope :in_subject, -> {
    joins(papers: { category: :subject }).distinct.where(
      papers: { categories: { subjects: { arxiv: it } } },
    )
  }

  before_validation :update_arxiv
  before_validation :update_variants

  def arxiv_base
    @arxiv_base ||= self.class.arxiv_base(name)
  end

  def name=(val)
    self.name_variants |= [val]
    super
  end

  # merge other authors that are variants of this
  def merge_variants(*others)
    others.each do
      self.papers |= it.papers
      self.users |= it.users
      self.name_variants |= [it.name] | it.name_variants
      save!
      it.destroy!
    end
  end

  class << self
    def arxiv_base(name)
      parts = name.split
      parts.reduce(parts.pop) { |res, item| "#{res}_#{item.first}" }.parameterize
    end
  end

  protected

  def update_variants
    self.name_variants |= [name]
  end

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
