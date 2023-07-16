require 'authentication/password_authenticator'

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    email_verified_at { Time.now }
    prefs { {} }
    #author { nil }
    transient do
      password { Faker::Internet.password }
    end
    encrypted_password do
      auth = Authentication::PasswordAuthenticator.new(salt_rounds: 1)
      auth.generate_hash(password)
    end
  end
end
