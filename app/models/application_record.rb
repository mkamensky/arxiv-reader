# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  self.abstract_class = true

  class << self
    # rubocop:disable Naming/PredicateName
    def has_many_through(assoc, vias, **opts)
      has_many vias, dependent: :destroy
      has_many assoc, through: vias, **opts
    end
    # rubocop:enable Naming/PredicateName

    def arxiv(id)
      @arxiv ||= {}
      @arxiv[id.to_s] ||= find_by(arxiv: id)
    end
  end
end
