FactoryBot.define do
  factory :tag do
    user
    sequence(:val) { "tag-#{it}" }
    title { "MyString" }
    color { "#2468ace0" }
  end
end
