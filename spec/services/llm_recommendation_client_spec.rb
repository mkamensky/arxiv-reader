require 'rails_helper'

RSpec.describe LlmRecommendationClient do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:paper) { create(:paper, category:) }
  let(:config) { double('context configuration') }
  let(:chat) { double('chat') }
  let(:context) { double('context', chat:) }
  let(:response) do
    double('response', finish_reason: :stop, parsed: {
      'recommendations' => [{ 'arxiv_id' => paper.arxiv, 'score' => 70, 'reason' => 'Relevant' }],
    })
  end

  before do
    user.usercats.create!(category:)
    allow(config).to receive(:request_timeout=)
    allow(RubyLLM).to receive(:context) do |&block|
      block.call(config)
      context
    end
    allow(chat).to receive(:with_instructions).and_return(chat)
    allow(chat).to receive(:with_schema).and_return(chat)
    allow(chat).to receive(:with_max_output_tokens).and_return(chat)
    allow(chat).to receive(:with_provider_options).and_return(chat)
    allow(chat).to receive(:ask).and_return(response)
  end

  it 'uses the site OpenAI key and disables response storage' do
    allow(Rails.configuration.x.llm_recommendations).
      to receive(:openai_api_key).and_return('site-openai-key')
    expect(config).to receive(:openai_api_key=).with('site-openai-key')
    expect(context).to receive(:chat).with(model: 'gpt-4o-mini', provider: :openai).and_return(chat)
    expect(chat).to receive(:with_provider_options).with(store: false).and_return(chat)

    result = described_class.new(user, 'openai').rank(favorites: [], followed: [], candidates: [paper])

    expect(result.first['arxiv_id']).to eq(paper.arxiv)
    expect(chat).to have_received(:ask) do |input|
      expect(JSON.parse(input)['candidates'].first['arxiv_id']).to eq(paper.arxiv)
    end
  end

  it 'uses only the personal Gemini key for a Gemini request' do
    user.update!(llm_mode: 'personal', llm_provider: 'gemini', llm_api_key: 'personal-gemini-key')
    expect(config).to receive(:gemini_api_key=).with('personal-gemini-key')
    expect(config).not_to receive(:openai_api_key=)
    expect(context).to receive(:chat).
      with(model: 'gemini-2.5-flash', provider: :gemini).and_return(chat)
    expect(chat).not_to receive(:with_provider_options)

    described_class.new(user, 'gemini').rank(favorites: [], followed: [], candidates: [paper])
  end

  it 'rejects an unavailable provider before contacting a model' do
    expect(RubyLLM).not_to receive(:context)

    expect { described_class.new(user, 'gemini') }.
      to raise_error(LlmRecommendationClient::Error, /Gemini API key/)
  end

  it 'does not accept an incomplete model response' do
    allow(Rails.configuration.x.llm_recommendations).
      to receive(:openai_api_key).and_return('site-openai-key')
    allow(config).to receive(:openai_api_key=)
    allow(context).to receive(:chat).and_return(chat)
    allow(chat).to receive(:ask).and_return(double('response', finish_reason: :max_tokens))

    expect do
      described_class.new(user, 'openai').rank(favorites: [], followed: [], candidates: [paper])
    end.to raise_error(LlmRecommendationClient::Error, /did not finish/)
  end

  it 'hides provider error details when a key is rejected' do
    allow(Rails.configuration.x.llm_recommendations).
      to receive(:openai_api_key).and_return('site-openai-key')
    allow(config).to receive(:openai_api_key=)
    allow(context).to receive(:chat).and_return(chat)
    allow(chat).to receive(:ask).
      and_raise(RubyLLM::UnauthorizedError, 'secret provider response')

    expect do
      described_class.new(user, 'openai').rank(favorites: [], followed: [], candidates: [paper])
    end.to raise_error(LlmRecommendationClient::Error, /OpenAI API key was rejected/)
  end
end
