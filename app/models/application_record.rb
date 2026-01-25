# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  require 'auto/core_ext/hash'
  primary_abstract_class
  self.abstract_class = true

  # for quasar components
  def label
    title
  end

  def value
    arxiv
  end

  class << self
    def decode_accents(string, **)
      LaTeX.decode(string, maths: false, strip_braces: false, **)
    end

    # rubocop:disable Naming/PredicatePrefix
    def has_many_through(assoc, vias, *, **)
      has_many vias, dependent: :destroy
      has_many assoc, *, through: vias, **
    end
    # rubocop:enable Naming/PredicatePrefix

    def arxiv(id)
      @arxiv ||= {}
      @arxiv[id.to_s] ||= find_by(arxiv: id)
    end

    def [](id)
      arxiv(id)
    end

    def inertia_params(**opts)
      {
        only: %i[id],
        methods: %i[label value],
      }.vdeep_merge(opts)
    end
  end

  delegate :decode_accents, to: :class

  def inertia_json(**)
    as_json(self.class.inertia_params(**))
  end
end
