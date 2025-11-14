module Arxived
  extend ActiveSupport::Concern

  included do
    include FriendlyId

    friendly_id :arxiv

    validates :arxiv, uniqueness: true, presence: true
  end
end
