FactoryBot.define do
  factory :category do
    sequence(:arxiv) { "factory-category-#{it}" }
    title { Faker::Dessert.flavor }
    subject
  end
end
