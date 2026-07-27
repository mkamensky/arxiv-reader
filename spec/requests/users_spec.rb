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
  end
end
