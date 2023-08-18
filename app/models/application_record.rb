# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  require 'auto/core_ext/hash'
  primary_abstract_class
  self.abstract_class = true

  class << self
    # rubocop:disable Naming/PredicateName
    def has_many_through(assoc, vias, **)
      has_many vias, dependent: :destroy
      has_many assoc, through: vias, **
    end
    # rubocop:enable Naming/PredicateName

    def arxiv(id)
      @arxiv ||= {}
      @arxiv[id.to_s] ||= find_by(arxiv: id)
    end

    def [](id)
      arxiv(id)
    end

    def inertia_params
      {}
    end
  end

  def inertia_json
    as_json(self.class.inertia_params)
  end
end
