FactoryBot.define do
  factory :subject do
    sequence(:arxiv) { "factory-subject-#{it}" }
    title { Faker::Dessert.flavor }
  end
end
