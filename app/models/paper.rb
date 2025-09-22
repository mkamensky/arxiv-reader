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
        category: Category.arxiv(apaper.primary),
        categories:
          apaper.secondaries.filter_map { Category.arxiv(it) }.uniq,
        authors: apaper.author_names.filter_map do
          Author.public_send(auth_find, name: it)
        end,
        submitted: apaper.submitted,
        revised: apaper.revised,
        title: apaper.title,
        arxiv: apaper.id,
        abstract: apaper.summary,
        version: apaper.version_id,
        comment: apaper.comment,
        abs: apaper.abs,
        pdf: apaper.pdf,
        #tags: apaper.aux_tags,
        journal_ref: apaper.journal_ref,
      }
    end

    def init_from_arxiv(apaper, **)
      new(attrs_from_arxiv(apaper, **))
    end

    def create_from_arxiv(apaper, **)
      create!(
        attrs_from_arxiv(
          apaper, auth_find: :find_or_create_by, **
        ),
      )
    rescue ActiveRecord::RecordInvalid => e
      debugger unless [
        'Validation failed: Version has already been taken',
        'Validation failed: Category must exist',
      ].include?(e.message)
    rescue StandardError => e
      debugger
    end

    def create_from_db(file = Rails.root.join('data', 'papers.db'))
      require 'arxiv/api'
      papers = Arxiv::Api::Paper.from_db(file)
      papers.each_value { create_from_arxiv(it) }
    end

    def inertia_params(**opts)
      super.vdeep_merge(
        only: %i[
          abs abstract comment category_id id journal_ref pdf
          submitted revised tags version
        ],
      )
    end
  end
end
