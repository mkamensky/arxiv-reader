# frozen_string_literal: true

class Subject < ApplicationRecord
  include FriendlyId

  friendly_id :arxiv

  ARXIV_EPOCH = Date.parse('2005-09-16').freeze
  public_constant :ARXIV_EPOCH

  has_many :categories, dependent: :destroy
  has_many :users, dependent: :nullify

  def papers
    Paper.with_subject(arxiv)
  end

  def first_after(date = ARXIV_EPOCH)
    papers.where(submitted: (date + 1.day)...).minimum(:submitted)
  end

  def last_before(date = Time.zone.today + 1.day)
    papers.where(submitted: ...date).maximum(:submitted)
  end

  def last_update
    last_before || ARXIV_EPOCH
  end

  def first_update
    (first_after || (1.day + ARXIV_EPOCH)) - 1.day
  end

  def refresh_from_arxiv(**opts)
    verbose = opts.delete(:verbose)
    require 'arxiv/api'
    res = []
    Arxiv::Api::Paper.from_oai(
      set: arxiv, from: last_update.to_date - 3.days, **opts,
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
