class LlmConnection < ApplicationRecord
  PROVIDERS = %w[openai gemini].freeze
  public_constant :PROVIDERS

  belongs_to :user

  validates :provider, inclusion: { in: PROVIDERS }, uniqueness: { scope: :user_id }
  validates :api_key_ciphertext, presence: true

  def api_key
    return if api_key_ciphertext.blank?

    encryptor.decrypt_and_verify(api_key_ciphertext)
  end

  def api_key=(value)
    return if value.blank?

    self.api_key_ciphertext = encryptor.encrypt_and_sign(value.strip)
  end

  protected

  def encryptor
    key = Rails.application.key_generator.generate_key('user-llm-api-key', 32)
    ActiveSupport::MessageEncryptor.new(key)
  end
end
