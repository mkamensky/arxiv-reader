FactoryBot.define do
  factory :category do
    sequence(:arxiv, 'AB') { |cc| "math.#{cc}" }
    title { Faker::Dessert.flavor }
    subject
  end
end
