require 'rails_helper'
require 'securerandom'

RSpec.describe "Papers", type: :request do
  let(:category) { create(:category) }

  describe "GET /papers" do
    let(:query) { "specsearch#{SecureRandom.hex(4)}" }
    let!(:matching_paper) do
      create(
        :paper,
        title: "A searchable paper about #{query}",
        abstract: 'A request spec should find this record.',
        category:,
      )
    end

    before do
      create(:paper, title: 'Unrelated paper', category:)
      get papers_path(q: query)
    end

    it 'renders the search page with matching papers' do
      papers = inertia.props[:papers].map(&:deep_symbolize_keys)

      expect(inertia).to render_component 'papers/index'
      expect(inertia.props[:total]).to eq(1)
      expect(papers).to include(include(id: matching_paper.id, label: matching_paper.title))
    end
  end

  describe "GET /papers/:id" do
    let!(:paper) { create(:paper, :current, title: 'A paper with a detail page', category:) }

    before { get paper_path("#{paper.arxiv}v3") }

    it 'renders the requested paper and ignores an arXiv version suffix' do
      paper_props = inertia.props[:paper].deep_symbolize_keys

      expect(inertia).to render_component 'papers/show'
      expect(paper_props).to include(id: paper.id, label: paper.title, value: paper.arxiv)
    end
  end
end
