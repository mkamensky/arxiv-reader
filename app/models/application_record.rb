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
    def decode_accents(string)
      return string unless string.respond_to?(:to_s)

      string = string.is_a?(String) ? string.dup : string.to_s

      LaTeX::Decode::Base.normalize(string)

      #Decode::Maths.decode!(string)

      LaTeX::Decode::Accents.decode!(string)
      LaTeX::Decode::Diacritics.decode!(string)
      LaTeX::Decode::Punctuation.decode!(string)
      LaTeX::Decode::Symbols.decode!(string)
      LaTeX::Decode::Greek.decode!(string)

      #Decode::Base.strip_braces(string)

      LaTeX.normalize_C(string)
      string
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
