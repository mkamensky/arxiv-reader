require 'rails_helper'

RSpec.describe RecommendationConsideration, type: :model do
  it 'records each paper only once per user' do
    user = create(:user)
    paper = create(:paper)
    user.recommendation_considerations.create!(paper:)

    expect(user.considered_papers).to contain_exactly(paper)
    expect(user.recommendation_considerations.build(paper:)).not_to be_valid
  end
end
