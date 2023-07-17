# frozen_string_literal: true

class Paper < ApplicationRecord
  include FriendlyId
  friendly_id :arxiv

  belongs_to :category

  has_many_through :categories, :categorisations
  has_many_through :authors, :authorships
  has_many_through :users, :bookmarks

  has_many_through :recommendees, :recommendations, source: :user

  validates :submitted, presence: true
  validates :abs, presence: true
  validates :version, uniqueness: { scope: :arxiv }

  scope :with_subject, ->(subj) {
    joins(category: :subject).distinct.where(
      category: { subjects: { arxiv: subj } },
    )
  }

  class << self
    def attrs_from_arxiv(apaper, **opts)
      auth_find = opts[:auth_find] || :find_or_initialize_by
      {
        category: Category.arxiv(apaper.category),
        categories: apaper.secondaries.map { |x| Category.arxiv(x) },
        authors: apaper.author_names.map do |x|
          Author.public_send(auth_find, name: x)
        end,
        submitted: apaper.submitted,
        revised: apaper.revised,
        title: apaper.title,
        arxiv: apaper.id,
        abstract: apaper.summary,
        version: "v#{apaper.version}",
        comment: apaper.comment,
        abs: apaper.abs,
        pdf: apaper.pdf,
        tags: apaper.aux_tags,
        journal_ref: apaper.journal_ref,
      }
    end

    def init_from_arxiv(apaper, **opts)
      new(attrs_from_arxiv(apaper, **opts))
    end

    def create_from_arxiv(apaper, **opts)
      create!(
        attrs_from_arxiv(
          apaper, auth_find: :find_or_create_by, **opts
        ),
      )
    rescue ActiveRecord::RecordInvalid => e
      raise e unless [
        'Validation failed: Version has already been taken',
        'Validation failed: Category must exist',
      ].include?(e.message)
    end

    def create_from_db(file = Rails.root.join('data', 'papers.db'))
      require 'arxiv/api'
      papers = Arxiv::Api::Paper.from_db(file)
      papers.each { |_k, v| create_from_arxiv(v) }
    end

    def inertia_params
      super.vdeep_merge(
        only: %i[
          abs arxiv abstract comment category_id id journal_ref pdf
          submitted revised tags title version
        ],
        include: {
          authors: { only: %i[name arxiv] },
        },
      )
    end
  end
end
