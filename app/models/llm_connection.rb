class LlmConnection < ApplicationRecord
  PROVIDERS = %w[openai gemini].freeze
  THINKING_LEVELS = %w[none minimal low medium high xhigh max].freeze
  public_constant :PROVIDERS
  public_constant :THINKING_LEVELS

  belongs_to :user

  validates :provider, inclusion: { in: PROVIDERS }, uniqueness: { scope: :user_id }
  validates :api_key_ciphertext, presence: true
  validates :model, format: { with: %r{\A[a-zA-Z0-9][a-zA-Z0-9._:/-]{0,127}\z} }, allow_nil: true
  validates :thinking_level, inclusion: { in: THINKING_LEVELS }, allow_nil: true
  validate :model_capabilities, if: -> { model.present? || thinking_level.present? }

  def self.model_options_for(provider)
    return [] if PROVIDERS.exclude?(provider)

    available = RubyLLM.models.by_provider(provider.to_sym).chat_models.listed
    available = available.select { it.supports?(:structured_output) }
    default_id = LlmRecommendationClient.model_for(provider)
    default_model = available.find { it.id == default_id }
    default = {
      value: '',
      label: "Provider default (#{default_id})",
      thinkingLevels: default_model ? thinking_levels_for(default_model) : [],
    }
    [default] + available.sort_by { [it.name.to_s.downcase, it.id] }.map do
      {
        value: it.id,
        label: "#{it.name} (#{it.id})",
        thinkingLevels: thinking_levels_for(it),
      }
    end
  end

  def self.thinking_levels_for(model)
    levels = model.reasoning_option_values(:effort) & THINKING_LEVELS
    return levels if levels.any?

    model.reasoning_option(:budget_tokens) ? %w[low medium high] : []
  end

  def api_key
    return if api_key_ciphertext.blank?

    encryptor.decrypt_and_verify(api_key_ciphertext)
  end

  def api_key=(value)
    return if value.blank?

    self.api_key_ciphertext = encryptor.encrypt_and_sign(value.strip)
  end

  protected

  def model_capabilities
    return if PROVIDERS.exclude?(provider)
    return if errors[:model].any?

    selected = RubyLLM.models.find(model.presence || LlmRecommendationClient.model_for(provider), provider: provider.to_sym)
    if selected.nil?
      errors.add(:model, 'is not in the local model registry')
    elsif !selected.supports?(:structured_output)
      errors.add(:model, 'must support structured output')
    elsif thinking_level.present? && self.class.thinking_levels_for(selected).exclude?(thinking_level)

      errors.add(:thinking_level, 'is not supported by this model')
    end
  rescue RubyLLM::ModelRegistryError
    errors.add(:model, 'could not be checked against the local model registry')
  rescue RubyLLM::ModelNotFoundError
    errors.add(:model, 'is not in the local model registry')
  end

  def encryptor
    key = Rails.application.key_generator.generate_key('user-llm-api-key', 32)
    ActiveSupport::MessageEncryptor.new(key)
  end
end
