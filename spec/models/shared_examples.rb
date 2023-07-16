require 'shared_context'

RSpec.shared_examples 'model examples' do
  include_context 'general context'

  it 'has a valid factory' do
    expect(object).to be_valid
  end
end
