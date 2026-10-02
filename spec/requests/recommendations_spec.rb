require 'rails_helper'

RSpec.describe 'Recommendations', type: :request do
  let(:user) { create(:user) }
  let(:session_record) { user.sessions.create!(user_agent: 'RSpec') }

  before do
    allow_any_instance_of(ApplicationController).
      to receive(:cur_session).and_return(session_record)
  end

  it 'shows only the signed-in user recommendations with paper data' do
    category = create(:category)
    user.usercats.create!(category:)
    paper = create(:paper, category:)
    pending = create(:paper, category:)
    user.recommendations.create!(paper:, reason: 'Related to your bookmarks')
    create(:user).recommendations.create!(paper: create(:paper))
    user.recommendations.create!(paper: create(:paper), reason: 'Outside followed categories')

    get recommendations_path

    expect(response).to have_http_status(:ok)
    expect(inertia).to render_component 'recommendations/show'
    items = inertia.props[:recommendations].map(&:deep_symbolize_keys)
    expect(items).to contain_exactly(include(reason: 'Related to your bookmarks', paper: include(id: paper.id)))
    expect(items.first).to include(provider: 'openai', secondOpinions: [])
    expect(inertia.props[:availableProviders]).to be_an(Array)
    expect(inertia.props[:pendingCount]).to eq(2)
    expect(inertia.props[:hasFollowedCategories]).to be(true)
    expect(inertia.props[:total]).to eq(1)
    expect(pending).to be_persisted
  end

  it 'accepts a second opinion only for the signed-in user recommendation' do
    recommendation = user.recommendations.create!(paper: create(:paper), score: 80)
    other = create(:user).recommendations.create!(paper: create(:paper), score: 70)
    recommender = instance_double(PaperRecommender)
    allow(PaperRecommender).to receive(:new).with(user).and_return(recommender)
    expect(recommender).to receive(:second_opinion!).with(recommendation, 'gemini')

    post recommendation_second_opinions_path(recommendation_id: recommendation.id),
         params: { provider: 'gemini' }
    expect(response).to redirect_to(recommendations_path)

    post recommendation_second_opinions_path(recommendation_id: other.id),
         params: { provider: 'gemini' }
    expect(response).to have_http_status(:not_found)
  end

  it 'rejects an unsupported second-opinion provider without saving data' do
    recommendation = user.recommendations.create!(paper: create(:paper), score: 80)

    post recommendation_second_opinions_path(recommendation_id: recommendation.id),
         params: { provider: 'untrusted' }

    expect(response).to redirect_to(recommendations_path)
    expect(flash[:alert]).to include('supported recommendation provider')
    expect(recommendation.second_opinions).to be_empty
  end

  it 'requires authentication for the recommendation page and refresh' do
    allow_any_instance_of(ApplicationController).
      to receive(:cur_session).and_return(nil)

    get recommendations_path
    expect(response).to redirect_to(root_url)

    post recommendations_path
    expect(response).to redirect_to(root_url)

    post recommendation_second_opinions_path(recommendation_id: 1),
         params: { provider: 'gemini' }
    expect(response).to redirect_to(root_url)
  end

  it 'paginates accumulated recommendations' do
    category = create(:category)
    user.usercats.create!(category:)
    papers = create_list(:paper, 21, category:)
    papers.each_with_index do |paper, index|
      user.recommendations.create!(paper:, score: index)
    end

    get recommendations_path(page: 2)

    expect(response).to have_http_status(:ok)
    expect(inertia.props[:page]).to eq(2)
    expect(inertia.props[:total]).to eq(21)
    expect(inertia.props[:recommendations].length).to eq(1)
  end

  it 'refreshes recommendations for the current user' do
    recommender = instance_double(PaperRecommender, refresh!: { processed: 2, remaining: 3 })
    allow(PaperRecommender).to receive(:new).with(user).and_return(recommender)

    post recommendations_path

    expect(response).to redirect_to(recommendations_path)
    expect(recommender).to have_received(:refresh!)
    expect(flash[:notice]).to include('3 remain')
  end

  it 'shows a useful error if recommendation generation fails' do
    detail = 'Gemini reached the output limit. Finish reason: max_tokens. Token usage: input 12000, output 8192.'
    allow_any_instance_of(PaperRecommender).to receive(:refresh!).
      and_raise(PaperRecommender::Error, detail)

    post recommendations_path

    expect(response).to redirect_to(recommendations_path)
    expect(flash[:alert]).to eq(detail)
  end
end
