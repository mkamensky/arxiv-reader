# frozen_string_literal: true

class Category < ApplicationRecord
  include FriendlyId
  friendly_id :arxiv

  has_many :papers, dependent: :destroy
  belongs_to :subject
  has_many_through :secondaries, :categorisations, source: :paper

  validates :arxiv, uniqueness: true

  scope :with_papers, -> { joins(:papers).distinct }

  def initialize(*args)
    super
    self.subject ||= Subject.from_category(arxiv)
  end

  # for quasar components
  def label
    title
  end

  def value
    arxiv
  end

  class << self
    def inertia_params
      super.vdeep_merge(
        only: %i[],
        methods: %i[label value],
      )
    end
  end
end
