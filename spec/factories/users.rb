FactoryBot.define do
  factory :user do
    password { "" }
    email { "MyString" }
    name { "MyString" }
    author { nil }
    email_verified_at { "2023-07-16 08:10:11" }
  end
end
