require 'rails_helper'

RSpec.describe LlmConnection do
  it 'lists structured-output models and their supported thinking levels by provider' do
    openai = described_class.model_options_for('openai')
    gemini = described_class.model_options_for('gemini')

    expect(openai.first).to include(value: '', label: /Provider default/)
    expect(openai).to include(include(value: 'gpt-4o-mini', thinkingLevels: []))
    expect(openai).to include(include(value: 'gpt-5-mini', thinkingLevels: include('low', 'medium', 'high')))
    expect(gemini).to include(include(value: 'gemini-2.5-flash', thinkingLevels: %w[low medium high]))
    expect(openai).not_to include(include(value: 'gemini-2.5-flash'))
  end

  it 'accepts a registry-supported effort beyond low, medium, and high' do
    user = create(
      :user, llm_mode: 'personal', llm_api_key: 'secret',
      llm_model: 'gpt-5-mini', llm_thinking_level: 'minimal'
    )

    expect(user.llm_connections.sole.reload.thinking_level).to eq('minimal')
  end
end
