require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  it 'normalizes email before validation' do
    user = build(:user, email: '  READER@example.COM  ')

    expect(user).to be_valid
    expect(user.email).to eq('reader@example.com')
  end

  it 'requires a unique email' do
    create(:user, email: 'duplicate@example.com')

    user = build(:user, email: ' DUPLICATE@example.com ')

    expect(user).not_to be_valid
    expect(user.errors[:email]).to include('has already been taken')
  end

  it 'authenticates with its password' do
    user = create(:user, password: 'correct horse battery staple')

    expect(user.authenticate('correct horse battery staple')).to eq(user)
    expect(user.authenticate('wrong password')).to be(false)
  end

  it 'uses the display name as label when present' do
    user = build(:user, name: 'Reader One', email: 'reader@example.com')

    expect(user.label).to eq('Reader One')
  end

  it 'falls back to email as label when name is blank' do
    user = build(:user, name: '', email: 'reader@example.com')

    expect(user.label).to eq('reader@example.com')
  end

  it 'uses email as value' do
    user = build(:user, email: 'reader@example.com')

    expect(user.value).to eq('reader@example.com')
  end

  it 'accepts nested tag attributes' do
    user = create(
      :user,
      tags_attributes: [
        { val: 'favorites', title: 'Favorites' },
      ],
    )

    expect(user.tags.map(&:val)).to contain_exactly('favorites')
  end

  it 'destroys dependent sessions and tags' do
    user = create(:user)
    user.sessions.create!(user_agent: 'RSpec')
    create(:tag, user:)

    expect { user.destroy! }.
      to change(Session, :count).by(-1).
      and change(Tag, :count).by(-1)
  end

  it 'exposes preference collections through join models' do
    user = create(:user)
    bookmarked = create(:paper)
    hidden = create(:paper)
    recommended = create(:paper)
    followed_author = create(:author)
    category = create(:category)

    user.bookmarks.create!(paper: bookmarked)
    user.hidden_papers.create!(paper: hidden)
    user.recommendations.create!(paper: recommended)
    user.followships.create!(author: followed_author)
    user.usercats.create!(category:)

    expect(user.bpapers).to contain_exactly(bookmarked)
    expect(user.hidden).to contain_exactly(hidden)
    expect(user.recommended).to contain_exactly(recommended)
    expect(user.fauthors).to contain_exactly(followed_author)
    expect(user.categories).to contain_exactly(category)
  end

  it 'encrypts a personal LLM key and never includes it in Inertia data' do
    user = create(:user, llm_mode: 'personal', llm_api_key: 'sk-test-secret')

    expect(user.reload.llm_api_key).to eq('sk-test-secret')
    expect(user.llm_connections.first.api_key_ciphertext).not_to include('sk-test-secret')
    expect(user.inertia_json.to_s).not_to include('sk-test-secret')
    expect(user.llm_key_configured?).to be(true)

    user.update!(llm_mode: 'anonymous', clear_llm_api_key: true)
    expect(user.reload.llm_api_key).to be_nil
  end

  it 'requires a key when personal LLM access is selected' do
    user = build(:user, llm_mode: 'personal')

    expect(user).not_to be_valid
    expect(user.errors[:llm_api_key]).to be_present
  end

  it 'keeps personal keys separate when switching providers' do
    user = create(:user, llm_mode: 'personal', llm_api_key: 'openai-secret')
    user.update!(llm_provider: 'gemini', llm_api_key: 'gemini-secret')

    expect(user.reload.llm_api_key).to eq('gemini-secret')
    expect(user.llm_connected_providers).to contain_exactly('openai', 'gemini')

    user.update!(llm_provider: 'openai')
    expect(user.reload.llm_api_key).to eq('openai-secret')
  end
end
