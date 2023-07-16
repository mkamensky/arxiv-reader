# frozen_string_literal: true

class Categorisation < ApplicationRecord
  belongs_to :paper
  belongs_to :category
end
