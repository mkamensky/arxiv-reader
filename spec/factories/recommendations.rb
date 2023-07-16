FactoryBot.define do
  factory :recommendation do
    paper
    user
    score { rand * 2 - 1 }
  end
end
