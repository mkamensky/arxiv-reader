# frozen_string_literal: true

class Paper < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_all,
                  against: { title: 'A', abstract: 'B', comment: 'C' },
                  using: {
                    tsearch: {
                      dictionary: 'english',
                      tsvector_column: 'searchable',
                    },
                  }

  include FriendlyId

  friendly_id :arxiv

  scope :not_hidden_by, -> { where.not(id: it&.hidden_ids) }

  belongs_to :category

  has_many_through :categories, :categorisations
  has_many_through :authors, :authorships
  has_many_through :users, :bookmarks

  has_many_through :recommendees, :recommendations, source: :user

  has_many_through :haters, :hidden_papers, source: :user

  validates :submitted, presence: true
  validates :abs, presence: true
  validates :version, uniqueness: { scope: :arxiv }

  scope :with_subject, -> {
    joins(category: :subject).distinct.where(
      category: { subjects: { arxiv: it } },
    )
  }

  def author_names
    authors.map(&:name).join('; ')
  end

  class << self
    # rubocop: disable Metrics/PerceivedComplexity
    # rubocop: disable Metrics/CyclomaticComplexity
    def attrs_from_arxiv(apaper, **opts)
      {
        category: Category.arxiv(apaper.primary),
        categories:
          apaper.secondaries.filter_map { Category.arxiv(it) }.uniq,
        authors: apaper.author_names.filter_map do
          if block_given?
            yield it
          elsif opts[:auth_find]
            Author.public_send(opts[:auth_find], it)
          else
            Author.find_by("? = ANY (name_variants)", it) ||
              Author.new(name: it)
          end
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
        primary: apaper.msc_class&.first || [],
        secondary: apaper.msc_class&.second || [],
      }
    end
    # rubocop: enable Metrics/PerceivedComplexity
    # rubocop: enable Metrics/CyclomaticComplexity

    def init_from_arxiv(apaper, **)
      new(attrs_from_arxiv(apaper, **))
    end

    # rubocop: disable Lint/Debugger, Lint/UselessAssignment
    def create_from_arxiv(apaper, **)
      create!(
        attrs_from_arxiv(apaper, **) do
          Author.find_by("? = ANY (name_variants)", it) ||
            Author.create!(name: it)
        end,
      )
    rescue ActiveRecord::RecordInvalid => e
      debugger if [
        'Validation failed: Version has already been taken',
        'Validation failed: Category must exist',
      ].exclude?(e.message) && Rails.env.local?
    rescue StandardError => e
      debugger if Rails.env.local?
    end
    # rubocop: enable Lint/Debugger, Lint/UselessAssignment

    def create_from_db(file = Rails.root.join('data', 'papers.db'))
      require 'arxiv/api'
      papers = Arxiv::Api::Paper.from_db(file)
      papers.each_value { create_from_arxiv(it) }
    end

    def inertia_params(**opts)
      super.vdeep_merge(
        only: %i[
          abs abstract comment category_id id journal_ref pdf
          submitted revised tags version primary secondary
        ],
      )
    end
  end
end
