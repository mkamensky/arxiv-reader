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
    Arxiv::Api::Paper.from_oai(
      set: arxiv, from: last_update.to_date, **opts,
    ) do |pp|
      next unless pp

      # rubocop: disable Rails/Output
      puts("Creating '#{pp.title}' (#{pp.id}) from the arxiv") if verbose
      # rubocop: enable Rails/Output
      Paper.create_from_arxiv(pp)
    end
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
