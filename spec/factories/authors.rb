FactoryBot.define do
  factory :author do
    name { Faker::Movies::Lebowski.character }
    #sequence(:arxiv) { "#{(name || '').parameterize}_#{it}" }

    transient do
      paper_count { 0 }
    end

    after(:create) do |author, ev|
      author.papers = create_list(:paper, ev.paper_count)
    end

    trait :with_papers do
      paper_count { [1, 2, 3].sample }
    end
  end
end
