# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :papers, dependent: :destroy
  belongs_to :subject
  has_many_through :secondaries, :categorisations, source: :paper

  validates :arxiv, uniqueness: true

  scope :with_papers, -> { joins(:papers).distinct }

  def initialize(*args)
    super
    self.subject ||= Subject.from_category(arxiv)
  end
end
