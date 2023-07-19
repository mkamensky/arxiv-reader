# frozen_string_literal: true

class Subject < ApplicationRecord
  include FriendlyId
  friendly_id :arxiv

  has_many :categories, dependent: :destroy

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
