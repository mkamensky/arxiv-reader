# frozen_string_literal: true

class Paper < ApplicationRecord
  belongs_to :category

  has_many_through :secondaries, :categorisations, source: :category
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
        secondaries: apaper.secondaries.map { |x| Category.arxiv(x) },
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
      find_or_create_by(
        attrs_from_arxiv(
          apaper, auth_find: :find_or_create_by, **opts
        ),
      )
    end

    def create_from_file(file = Rails.root.join('data', 'db.json'))
      require 'arxiv/api'
      papers = Arxiv::Api::Paper.from_file(file)
      papers.each { |_k, v| create_from_arxiv(v) }
    end
  end
end
