FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    prefs { {} }
    # author { nil }
    password { Faker::Internet.password }
  end
end
