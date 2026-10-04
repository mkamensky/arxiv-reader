# rubocop:disable Style/ItBlockParameter
require 'rails_helper'

RSpec.describe PaperRecommender do
  let(:user) { create(:user, llm_mode: 'personal', llm_api_key: 'sk-test') }
  let(:category) { create(:category) }
  let(:favorite) { create(:paper, category:, title: 'Favorite topic') }
  let(:candidate) { create(:paper, category:, title: 'Related new paper') }
  let(:hidden) { create(:paper, category:) }

  before do
    user.usercats.create!(category:)
    user.bookmarks.create!(paper: favorite)
    user.hidden_papers.create!(paper: hidden)
  end

  it 'considers followed-category papers and persists only eligible model choices' do
    candidate
    other_category_paper = create(:paper)
    client = instance_double(LlmRecommendationClient, model: 'gpt-4o-mini')
    allow(LlmRecommendationClient).to receive(:new).with(user, 'openai').and_return(client)
    allow(client).to receive(:rank) do |favorites:, followed:, candidates:|
      expect(favorites).to include(favorite)
      expect(followed).to be_empty
      expect(candidates).to include(candidate)
      expect(candidates).not_to include(favorite, hidden, other_category_paper)
      [
        { 'arxiv_id' => hidden.arxiv, 'score' => 99, 'reason' => 'Should be rejected' },
        { 'arxiv_id' => candidate.arxiv, 'score' => 82, 'reason' => 'Matches the favorite topic' },
      ]
    end

    result = described_class.new(user).refresh!

    expect(user.recommendations.pluck(:paper_id)).to eq([candidate.id])
    expect(user.recommendations.first.reason).to eq('Matches the favorite topic')
    expect(user.recommendations.first.score).to eq(82)
    expect(user.recommendations.first.provider).to eq('openai')
    expect(user.recommendations.first.model).to eq('gpt-4o-mini')
    expect(user.considered_papers).to contain_exactly(candidate)
    expect(result).to eq(processed: 1, remaining: 0)
  end

  it 'keeps existing recommendations when the service fails' do
    user.recommendations.create!(paper: candidate)
    client = instance_double(LlmRecommendationClient)
    allow(LlmRecommendationClient).to receive(:new).and_return(client)
    allow(client).to receive(:rank).and_raise(LlmRecommendationClient::Error, 'offline')

    expect { described_class.new(user).refresh! }.to raise_error(PaperRecommender::Error, 'offline')
    expect(user.recommendations.pluck(:paper_id)).to eq([candidate.id])
    expect(user.recommendation_considerations.count).to eq(0)
  end

  it 'reports an invalid personal key without exposing the provider response' do
    candidate
    client = instance_double(LlmRecommendationClient)
    allow(LlmRecommendationClient).to receive(:new).and_return(client)
    allow(client).to receive(:rank).
      and_raise(LlmRecommendationClient::Error, 'The Openai API key was rejected.')

    expect { described_class.new(user).refresh! }.
      to raise_error(PaperRecommender::Error, /API key was rejected/)
  end

  it 'requires a followed category before contacting the service' do
    user.usercats.delete_all
    expect(LlmRecommendationClient).not_to receive(:new)

    expect { described_class.new(user).refresh! }.
      to raise_error(PaperRecommender::Error, /Follow at least one category/)
  end

  it 'uses the selected provider when anonymous mode is selected' do
    user.update!(llm_mode: 'anonymous')
    candidate
    client = instance_double(LlmRecommendationClient, model: 'gpt-4o-mini')
    allow(LlmRecommendationClient).to receive(:new).with(user, 'openai').and_return(client)
    allow(client).to receive(:rank).
      and_return([{ 'arxiv_id' => candidate.arxiv, 'score' => 75, 'reason' => 'Related' }])
    recommender = described_class.new(user)

    recommender.refresh!

    expect(user.recommendations.pluck(:paper_id)).to eq([candidate.id])
  end

  it 'continues through every pending paper across batches, even when a batch recommends none' do
    stub_const('PaperRecommender::BATCH_SIZE', 2)
    papers = create_list(:paper, 3, category:)
    recommender = described_class.new(user)
    client = instance_double(LlmRecommendationClient, rank: [])
    allow(LlmRecommendationClient).to receive(:new).and_return(client)

    expect(recommender.pending_count).to eq(3)
    expect(recommender.refresh!).to eq(processed: 2, remaining: 1)
    expect(recommender.refresh!).to eq(processed: 1, remaining: 0)
    expect(user.reload.considered_papers).to contain_exactly(*papers)
    expect(recommender.refresh!).to eq(processed: 0, remaining: 0)
  end

  it 'includes older papers and newly followed categories without reconsidering completed papers' do
    older = create(:paper, category:, submitted: 10.years.ago.to_date, version: 'v1')
    recommender = described_class.new(user)
    client = instance_double(LlmRecommendationClient, rank: [])
    allow(LlmRecommendationClient).to receive(:new).and_return(client)

    expect(recommender.pending_count).to eq(1)
    recommender.refresh!
    expect(recommender.pending_count).to eq(0)

    another_category = create(:category)
    newly_in_scope = create(:paper, category: another_category)
    user.usercats.create!(category: another_category)

    expect(recommender.pending_count).to eq(1)
    recommender.refresh!
    expect(user.considered_papers).to contain_exactly(older, newly_in_scope)
  end

  it 'does not expand eligibility to a bookmarked paper category that is not followed' do
    other_category = create(:category)
    user.bookmarks.create!(paper: create(:paper, category: other_category))
    create(:paper, category: other_category)

    expect(described_class.new(user).pending_count).to eq(0)
  end

  it 'prevents overlapping refreshes for one user' do
    user.update_columns(recommendation_processing_started_at: Time.current)
    create(:paper, category:)
    client = instance_double(LlmRecommendationClient)
    allow(LlmRecommendationClient).to receive(:new).and_return(client)
    expect(client).not_to receive(:rank)

    expect { described_class.new(user).refresh! }.
      to raise_error(PaperRecommender::Error, /already being refreshed/)
  end

  it 'saves a Gemini second opinion without reconsidering the paper' do
    user.update!(llm_provider: 'gemini', llm_api_key: 'gemini-key')
    user.update!(llm_provider: 'openai')
    recommendation = user.recommendations.create!(paper: candidate, provider: 'openai', score: 80)
    client = instance_double(LlmRecommendationClient, model: 'gemini-2.5-flash')
    allow(LlmRecommendationClient).to receive(:new).with(user, 'gemini').and_return(client)
    allow(client).to receive(:rank).
      and_return([{ 'arxiv_id' => candidate.arxiv, 'score' => 45, 'reason' => 'Less aligned' }])

    described_class.new(user).second_opinion!(recommendation, 'gemini')

    opinion = recommendation.second_opinions.sole
    expect(opinion.attributes).to include('provider' => 'gemini', 'model' => 'gemini-2.5-flash')
    expect(opinion.score).to eq(45)
    expect(user.recommendation_considerations.count).to eq(0)
    expect { described_class.new(user).second_opinion!(recommendation, 'gemini') }.
      to raise_error(PaperRecommender::Error, /already exists/)
  end
end
# rubocop:enable Style/ItBlockParameter
