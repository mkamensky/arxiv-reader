require 'rails_helper'

RSpec.describe "Subjects", type: :request do
  let!(:default_subject) do
    Subject.find_or_create_by!(arxiv: 'math') { it.title = 'Mathematics' }
  end

  describe "GET /subjects/:id" do
    let(:date) { Date.new(2026, 1, 15) }
    let(:subject) { create(:subject) }
    let(:category) { create(:category, arxiv: "#{subject.arxiv}.AG", subject:) }
    let!(:paper) { create(:paper, category:, submitted: date) }

    before do
      create(:paper, category:, submitted: date - 1.day)
      get subject_path(subject.arxiv, date: date.iso8601)
    end

    it 'renders the subject page for the requested date' do
      subject_props = inertia.props[:subject].deep_symbolize_keys

      expect(inertia).to render_component 'subjects/show'
      expect(subject_props).to include(value: subject.arxiv, label: subject.title)
      expect(Date.parse(inertia.props[:date].to_s)).to eq(date)
    end

    it 'groups papers by category for the requested date' do
      papers = inertia.props[:papers][category.arxiv].map(&:deep_symbolize_keys)

      expect(papers).to contain_exactly(include(id: paper.id, label: paper.title))
    end
  end
end
