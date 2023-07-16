FactoryBot.define do
  factory :subject do
    sequence(:arxiv, 'AB') { |cc| "#{%w[math physics stat bio].sample}-#{cc}" }
    title { Faker::Dessert.flavor }
  end
end
