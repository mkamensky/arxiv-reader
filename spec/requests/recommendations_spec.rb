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
    shared_user = inertia.props.dig(:auth, :user).deep_stringify_keys
    expect(shared_user['recommendation_providers'][paper.id.to_s]).to eq('openai')
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

  it 'returns to the current paper list after a second opinion from another screen' do
    recommendation = user.recommendations.create!(paper: create(:paper), score: 80)
    recommender = instance_double(PaperRecommender)
    allow(PaperRecommender).to receive(:new).with(user).and_return(recommender)
    allow(recommender).to receive(:second_opinion!)

    post recommendation_second_opinions_path(recommendation_id: recommendation.id),
         params: { provider: 'gemini' }, headers: { 'HTTP_REFERER' => papers_path }

    expect(response).to redirect_to(papers_path)
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

    get recommendations_sidebar_path
    expect(response).to redirect_to(root_url)

    get paper_recommendation_assessment_path(paper_id: 1)
    expect(response).to redirect_to(root_url)

    post recommendations_path
    expect(response).to redirect_to(root_url)

    post recommendation_second_opinions_path(recommendation_id: 1),
         params: { provider: 'gemini' }
    expect(response).to redirect_to(root_url)

    post paper_recommendation_feedback_path(paper_id: 1), params: { sentiment: 'positive' }
    expect(response).to redirect_to(root_url)
  end

  it 'loads eligible recommended papers in sidebar pages without exposing other users or negative feedback' do
    category = create(:category)
    user.usercats.create!(category:)
    papers = create_list(:paper, 21, category:)
    papers.each { user.recommendations.create!(paper: it) }
    excluded = papers.first
    user.recommendation_feedbacks.create!(paper: excluded, sentiment: 'negative')
    manual = create(:paper, category:)
    user.recommendation_feedbacks.create!(paper: manual, sentiment: 'positive')
    create(:user).recommendations.create!(paper: create(:paper, category:))

    get recommendations_sidebar_path
    first_page = response.parsed_body
    expect(first_page['papers'].length).to eq(20)
    expect(first_page['nextPage']).to eq(2)
    expect(first_page['papers'].map { it['id'] }).not_to include(excluded.id)

    get recommendations_sidebar_path(page: 2)
    second_page = response.parsed_body
    expect(second_page['papers'].length).to eq(1)
    expect(second_page['nextPage']).to be_nil
    expect((first_page['papers'] + second_page['papers']).map { it['id'] }).to include(manual.id)
  end

  it 'loads only the signed-in user assessment and its second opinions' do
    paper = create(:paper)
    recommendation = user.recommendations.create!(paper:, score: 82, reason: 'A good match')
    recommendation.second_opinions.create!(provider: 'gemini', model: 'gemini-2.5-flash',
                                           score: 75, reason: 'Some overlap')
    other = create(:user).recommendations.create!(paper: create(:paper))

    get paper_recommendation_assessment_path(paper_id: paper.id)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['recommendation']).to include(
      'id' => recommendation.id, 'score' => 82, 'reason' => 'A good match',
      'secondOpinions' => [include('provider' => 'gemini', 'reason' => 'Some overlap')],
    )

    get paper_recommendation_assessment_path(paper_id: other.paper_id)
    expect(response).to have_http_status(:not_found)
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

  it 'stores positive feedback and lists a manually recommended eligible paper' do
    category = create(:category)
    user.usercats.create!(category:)
    paper = create(:paper, category:)

    post paper_recommendation_feedback_path(paper_id: paper.id), params: { sentiment: 'positive' }

    expect(response).to redirect_to(recommendations_path)
    expect(user.reload.recommendation_feedbacks.sole.sentiment).to eq('positive')
    expect(user.recommended_ids).to include(paper.id)
    expect(PaperRecommender.new(user).pending_count).to eq(0)

    get recommendations_path
    expect(inertia.props[:total]).to eq(1)
    expect(inertia.props[:recommendations].sole.deep_symbolize_keys).
      to include(id: "manual-#{paper.id}", reason: nil, paper: include(id: paper.id))
  end

  it 'records negative feedback when a model recommendation is turned off and restores it on positive feedback' do
    category = create(:category)
    user.usercats.create!(category:)
    paper = create(:paper, category:)
    user.recommendations.create!(paper:, score: 81)

    post paper_recommendation_feedback_path(paper_id: paper.id), params: { sentiment: 'negative' }
    expect(user.reload.recommendation_feedbacks.sole.sentiment).to eq('negative')
    expect(user.recommended_ids).not_to include(paper.id)
    get recommendations_path
    expect(inertia.props[:total]).to eq(0)

    post paper_recommendation_feedback_path(paper_id: paper.id), params: { sentiment: 'positive' }
    expect(user.reload.recommendation_feedbacks.sole.sentiment).to eq('positive')
    expect(user.recommended_ids).to include(paper.id)
    get recommendations_path
    expect(inertia.props[:total]).to eq(1)
    expect(inertia.props[:recommendations].sole.deep_symbolize_keys[:score]).to eq(81)
  end

  it 'rejects invalid feedback and keeps another user’s feedback isolated' do
    paper = create(:paper)
    other = create(:user)
    other.recommendation_feedbacks.create!(paper:, sentiment: 'positive')

    post paper_recommendation_feedback_path(paper_id: paper.id), params: { sentiment: 'neutral' }
    expect(user.recommendation_feedbacks).to be_empty
    expect(flash[:alert]).to include('positive or negative')

    post paper_recommendation_feedback_path(paper_id: paper.id), params: { sentiment: 'negative' }
    expect(other.recommendation_feedbacks.sole.reload.sentiment).to eq('positive')
    expect(user.recommendation_feedbacks.sole.sentiment).to eq('negative')
  end

  it 'paginates model and manual recommendations together without duplicates' do
    category = create(:category)
    user.usercats.create!(category:)
    papers = create_list(:paper, 20, category:)
    papers.each { user.recommendations.create!(paper: it) }
    manual = create(:paper, category:)
    user.recommendation_feedbacks.create!(paper: manual, sentiment: 'positive')

    get recommendations_path(page: 2)

    expect(inertia.props[:total]).to eq(21)
    expect(inertia.props[:recommendations].sole.deep_symbolize_keys[:paper][:id]).to eq(manual.id)
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
