class PaperVersion < ApplicationVersion
  belongs_to :item, class_name: item_type
end
