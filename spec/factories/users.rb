FactoryBot.define do
  factory :user do
    sequence(:email) { "user#{it}@example.com" }
    password { "password" }
  end
end
