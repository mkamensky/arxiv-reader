# frozen_string_literal: true

class Subject < ApplicationRecord
  include FriendlyId

  friendly_id :arxiv

  ARXIV_EPOCH = Date.parse('1991-08-14').freeze
  public_constant :ARXIV_EPOCH

  has_many :categories, dependent: :destroy

  def papers
    Paper.with_subject(arxiv)
  end

  def last_update
    papers.maximum(:submitted) || ARXIV_EPOCH
  end

  def refresh_from_arxiv(**opts)
    verbose = opts.delete(:verbose)
    require 'arxiv/api'
    res = []
    Arxiv::Api::Paper.from_oai(
      set: arxiv, from: last_update.to_date, **opts,
    ) do
      next unless it

      # rubocop: disable Rails/Output
      puts("Creating '#{it.title}' (#{it.id}) from the arxiv") if verbose
      # rubocop: enable Rails/Output
      if (paper = Paper.create_from_arxiv(it))
        res.push(paper)
      end
    end
    res
  end

  class << self
    def inertia_params
      super.vdeep_merge(
        include: {
          categories: Category.inertia_params,
        },
      )
    end

    def from_category(cid)
      cid = cid.to_s.downcase
      ar = case cid
           when 'astro-ph'
             'astro-ph'
           when /^(.*)\./
             $1
           else
             'physics'
      end
      arxiv(ar)
    end
  end
end
