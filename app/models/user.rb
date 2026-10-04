# frozen_string_literal: true

class User < ApplicationRecord
  #include FriendlyId

  #friendly_id :value, use: %i[finders]
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :llm_connections, dependent: :destroy, autosave: true
  has_many :recommendation_feedbacks, dependent: :destroy
  validates :llm_mode, inclusion: { in: %w[anonymous personal] }
  validates :llm_provider, inclusion: { in: LlmConnection::PROVIDERS }
  validate :personal_llm_key_present
  before_validation :apply_llm_key_changes

  belongs_to :author, optional: true
  has_many_through :bpapers, :bookmarks, source: :paper
  # Ranked recommendations generated on demand
  has_many_through :recommended, :recommendations, source: :paper
  has_many_through :considered_papers, :recommendation_considerations, source: :paper
  has_many_through :fauthors, :followships, -> { order(:name) }, source: :author

  # papers the user doesn't want to see
  has_many_through :hidden, :hidden_papers, source: :paper

  belongs_to :subject, optional: true # default subject
  has_many_through :categories, :usercats

  has_many :tags, dependent: :destroy
  accepts_nested_attributes_for :tags

  validates :email, presence: true, uniqueness: true
  normalizes :email, with: -> { it.strip.downcase }

  def self.inertia_params(**)
    super.vdeep_merge(only: %i[avatar])
  end

  def label
    name.presence || email
  end

  def value
    email
  end

  def llm_api_key
    llm_connection&.api_key
  end

  def llm_api_key=(value)
    @pending_llm_api_key = value
  end

  def clear_llm_api_key=(value)
    @clear_llm_api_key = ActiveModel::Type::Boolean.new.cast(value)
  end

  def llm_model=(value)
    @pending_llm_model = value.presence
  end

  def llm_thinking_level=(value)
    @pending_llm_thinking_level = value.presence
  end

  def llm_key_configured?
    llm_connection&.api_key_ciphertext.present? && !llm_connection.marked_for_destruction?
  end
  alias_method :llm_key_configured, :llm_key_configured?

  def llm_connected_providers
    llm_connections.reject(&:marked_for_destruction?).map(&:provider)
  end

  def llm_settings
    llm_connections.reject(&:marked_for_destruction?).to_h do
      [it.provider, { model: it.model, thinking_level: it.thinking_level }]
    end
  end

  def recommended_ids
    generated = recommendations.where.not(
      paper_id: recommendation_feedbacks.where(sentiment: 'negative').select(:paper_id),
    ).pluck(:paper_id)
    (generated + recommendation_feedbacks.where(sentiment: 'positive').pluck(:paper_id)).uniq
  end

  def recommendation_providers
    recommendations.pluck(:paper_id, :provider).to_h
  end

  protected

  def llm_connection
    llm_connections.find { it.provider == llm_provider }
  end

  def apply_llm_key_changes
    return if LlmConnection::PROVIDERS.exclude?(llm_provider)

    if @pending_llm_api_key.present?
      connection = llm_connection || llm_connections.build(provider: llm_provider)
      connection.api_key = @pending_llm_api_key
    elsif @clear_llm_api_key
      llm_connection&.mark_for_destruction
    end
    if llm_mode == 'personal' && !@clear_llm_api_key && llm_connection
      llm_connection.model = @pending_llm_model if instance_variable_defined?(:@pending_llm_model)
      llm_connection.thinking_level = @pending_llm_thinking_level if instance_variable_defined?(:@pending_llm_thinking_level)
    end
    @pending_llm_api_key = nil
    remove_instance_variable(:@pending_llm_model) if instance_variable_defined?(:@pending_llm_model)
    remove_instance_variable(:@pending_llm_thinking_level) if instance_variable_defined?(:@pending_llm_thinking_level)
    @clear_llm_api_key = false
  end

  def personal_llm_key_present
    errors.add(:llm_api_key, 'is required for a personal connection') if
      llm_mode == 'personal' && !llm_key_configured?
  end
end
