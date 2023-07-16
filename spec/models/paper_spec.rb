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
    let(:subj1) { create(:subject) }
    let(:subj2) { create(:subject) }
    let(:cat1) { create(:category, subject: subj1) }
    let(:cat2) { create(:category, subject: subj1) }
    let(:cat3) { create(:category, subject: subj2) }

    before do
      @paper1 = create(:paper, category: cat1)
      @paper2 = create(:paper, category: cat2)
      @paper3 = create(:paper, category: cat3)
    end

    it 'retrieves all papers in the given subject' do
      expect(Paper.with_subject(subj1.arxiv))
        .to match_array([@paper1, @paper2])
    end
  end

end
