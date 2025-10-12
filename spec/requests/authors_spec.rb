require 'rails_helper'

RSpec.describe "Authors:", type: :request, inertia: true do
  let!(:author) { create(:author, :with_papers, name: 'The Dude') }
  describe "GET /authors" do
    let!(:author2) { create(:author, :with_papers, name: 'Jeff Lebowski') }

    before { get authors_path(q: 'dude') }
    it 'renders author index page' do
      expect(inertia).to render_component 'authors/index'
    end

    it 'sends correct props' do
      expect(inertia).to include_props(:authors)
    end

    it 'finds the right authors' do
      expect(inertia.props[:authors]).to include(include(label: author.name))
    end

    it 'does not find the wrong authors' do
      expect(inertia.props[:authors]).not_to include(include(label: author2.name))
    end
  end
  describe "GET /authors/:id" do
    before { get author_path(id: author.arxiv) }

    it 'renders author show page' do
      expect(inertia).to render_component 'authors/show'
    end

    it 'sends correct props' do
      expect(inertia).to include_props(:author)
    end

    it 'sends the correct author' do
      expect(inertia.props[:author]).to include("label" => author.name)
    end
  end
end
