require 'rails_helper'

RSpec.describe "Categories", type: :request do
  let!(:default_subject) do
    Subject.find_or_create_by!(arxiv: 'math') { it.title = 'Mathematics' }
  end

  describe "GET /subjects/:id" do
    let(:date) { Time.zone.today }
    let(:subject) { create(:subject) }
    let!(:category) do
      create(:category, arxiv: "#{subject.arxiv}.AG", title: 'Algebraic Geometry', subject:)
    end
    let!(:paper) { create(:paper, category:, submitted: date) }

    before { get subject_path(subject.arxiv, date: date.iso8601) }

    it 'renders categories for the selected subject' do
      categories = inertia.props[:subject][:categories].map(&:deep_symbolize_keys)

      expect(categories).to include(
        include(label: category.title, value: category.arxiv),
      )
    end
  end
end
