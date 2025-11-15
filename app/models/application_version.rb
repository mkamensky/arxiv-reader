# rubocop: disable Rails/ApplicationRecord
class ApplicationVersion < ActiveRecord::Base
  include PaperTrail::VersionConcern

  self.abstract_class = true

  def self.item_type
    name.sub(/Version$/, '')
  end

  delegate :item_type, to: :class

  def item_type=(val)
  end
end

# rubocop: enable Rails/ApplicationRecord
