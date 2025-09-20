# frozen_string_literal: true

class Category < ApplicationRecord
  include FriendlyId

  friendly_id :arxiv

  has_many :papers, dependent: :destroy
  belongs_to :subject
  has_many_through :secondaries, :categorisations, source: :paper

  delegate :refresh_from_arxiv, to: :subject

  validates :arxiv, uniqueness: true

  scope :with_papers, -> { joins(:papers).distinct }

  def initialize(*args)
    super
    self.subject ||= Subject.from_category(arxiv)
  end

  class << self
    def arxiv(id)
      # https://arxiv.org/category_taxonomy
      id = 'eess.SY' if id == 'cs.SY'
      id = 'math.NA' if id == 'cs.NA'
      super
    end
  end
end
