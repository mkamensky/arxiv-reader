require 'rails_helper'
require 'securerandom'

RSpec.describe "Users", type: :request do
  describe "POST /users" do
    let(:email) { "request-#{SecureRandom.hex(4)}@example.com" }

    it 'creates a user, starts a session, and redirects home' do
      expect do
        post users_path, params: {
          user: {
            email:,
            password: 'correct horse battery staple',
            name: 'Request Spec User',
          },
        }
      end.to change(User, :count).by(1).and change(Session, :count).by(1)

      user = User.find_by!(email:)

      expect(response).to redirect_to(root_url)
      expect(user.sessions).to exist
      expect(response.headers['Set-Cookie'].join).to include('session_id=')
    end

    it 'does not create a user with invalid params' do
      expect do
        post users_path, params: {
          user: {
            email: '',
            password: 'correct horse battery staple',
          },
        }
      end.to change(User, :count).by(0).and change(Session, :count).by(0)

      expect(response).to redirect_to(root_url)
    end
  end

  describe "PATCH /users/:id" do
    let(:user) { create(:user, name: 'Before') }
    let!(:session_record) do
      user.sessions.create!(user_agent: 'RSpec')
    end

    before do
      allow_any_instance_of(ApplicationController).
        to receive(:cur_session).and_return(session_record)
    end

    it 'updates the authenticated user' do
      patch user_path(user), params: {
        user: {
          name: 'After',
        },
      }

      expect(response).to redirect_to(root_url)
      expect(user.reload.name).to eq('After')
    end

    it 'saves a personal key without returning it in page props' do
      patch user_path(user), params: {
        user: { llm_mode: 'personal', llm_api_key: 'sk-request-secret' },
      }

      expect(response).to redirect_to(root_url)
      expect(user.reload.llm_api_key).to eq('sk-request-secret')

      get user_path(user)
      expect(response).to have_http_status(:ok)
      expect(inertia).to render_component 'users/show'
      expect(inertia.props.dig(:auth, :user, 'llm_key_configured')).to be(true)
      expect(response.body).not_to include('sk-request-secret')
    end

    it 'saves separate keys for OpenAI and Gemini' do
      patch user_path(user), params: {
        user: { llm_mode: 'personal', llm_api_key: 'openai-secret' },
      }
      patch user_path(user), params: {
        user: { llm_provider: 'gemini', llm_api_key: 'gemini-secret' },
      }

      expect(user.reload.llm_api_key).to eq('gemini-secret')
      expect(user.llm_connected_providers).to contain_exactly('openai', 'gemini')
      get user_path(user)
      expect(inertia.props.dig(:auth, :user, 'llm_provider')).to eq('gemini')
      expect(response.body).not_to include('openai-secret', 'gemini-secret')
    end

    it 'rejects invalid personal mode and updates to another user' do
      patch user_path(user), params: { user: { llm_mode: 'personal' } }
      expect(user.reload.llm_mode).to eq('anonymous')

      other_user = create(:user)
      expect { patch user_path(other_user), params: { user: { name: 'Changed' } } }.
        not_to(change { other_user.reload.name })
    end
  end
end
