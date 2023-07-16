require 'models/shared_examples'

RSpec.describe Author, type: :model do
  include_standard_examples

  describe '#name' do
    it 'validates presence' do
      expect(build(type, name: nil)).to_not be_valid
    end
  end

  describe '#arxiv' do
    it 'validates uniqueness' do
      object.save
      expect(build(type, arxiv: object.arxiv)).to_not be_valid
    end
  end

  context 'before_save' do
    describe 'arxiv id updating' do
      let!(:old) { object.arxiv }

      before do
        object.save
        object.reload
      end

      context 'when arxiv id exists' do
        it 'leaves it unmodified' do
          expect(object.arxiv).to eq(old)
        end
      end

      context 'when arxiv id does not exist' do
        let(:object) { build(type, name: 'Andre Weil', arxiv: nil) }
        it 'creates a new id' do
          expect(object.arxiv).to eq('weil_a_1_X')
        end
      end
    end
  end
end

