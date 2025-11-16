require 'models/shared_examples'

RSpec.describe Paper, type: :model do
  include_standard_examples

  describe '#submitted' do
    it 'validates presence' do
      expect(build(type, submitted: nil)).not_to be_valid
    end
  end

  describe '#abs' do
    it 'validates presence' do
      expect(build(type, abs: nil)).not_to be_valid
    end
  end

  describe '.with_subject' do
    let(:subj1) { Subject.first }
    let(:subj2) { Subject.last }
    let(:cat1) { subj1.categories.first }
    let(:cat2) { subj1.categories.last }
    let(:cat3) { subj2.categories.take }

    before do
      @paper1 = create(:paper, category: cat1)
      @paper2 = create(:paper, category: cat2)
      @paper3 = create(:paper, category: cat3)
    end

    it 'retrieves all papers in the given subject' do
      expect(Paper.with_subject(subj1.arxiv)).
        to match_array([@paper1, @paper2])
    end
  end

  describe '.create_from_arxiv', versioning: true do
    let(:apaper) do
      Arxiv::Api::Paper.new(
        id: '0123.4567',
        title: 'Some stuff I thought about',
        version: {
          v1: {
            'date' => Time.zone.today - 1.month,
            size: '5kb',
          },
          v2: {
            'date' => Time.zone.today - 1.week,
            size: '4kb',
            source_type: 'D',
          },
        },
        comments: 'initial version',
        submitter: 'Mustrum Ridcully',
        authors: ['Mustrum Ridcully'],
        url: 'https://arxiv.org/0123.4567',
        category: 'math.AG',
        categories: %w[math.AG math.CA],
        msc_class: [["03D20"], nil],
        abstract: 'We do some stuff',
      )
    end

    let(:apaper2) do
      res = apaper
      res.version[:v3] = { 'date' => Time.zone.today }
      res
    end

    let(:call) do
      warn "CALLING CFA"
      Paper.create_from_arxiv(apaper)
    end

    context 'when no paper with this arxiv id exists' do
      it 'creates the paper' do
        expect { Paper.create_from_arxiv(apaper) }.to change { Paper.count }.by(1)
      end
    end

    context 'when a paper with the arxiv id exists and version is new' do
      it 'creates a new version of the paper' do
        paper = Paper.create_from_arxiv(apaper)
        expect { Paper.create_from_arxiv(apaper2) }.
          to_not(change { Paper.count })
        expect(paper).to have_a_version_with_changes version: 'v3'
        expect(paper).to have_a_version_with_changes version: 'v2'
      rescue NoMethodError => e
        debugger
      end
    end
  end
end
