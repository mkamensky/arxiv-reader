FactoryBot.define do
  factory :paper do
    sequence(:arxiv) { "factory-paper-#{it}" }
    title { Faker::ChuckNorris.fact }
    abstract { Faker::Movies::Lebowski.quote }
    abs { Faker::Internet.url }
    pdf { Faker::Internet.url }
    tags { [] }
    journal_ref { Faker::Lorem.sentence }
    comment { Faker::Movie.quote }
    version { %w[v1 v2 v3].sample }
    submitted { Faker::Date.between(from: 3.years.ago, to: 1.day.ago) }
    revised do
      if version == 'v1' || submitted.blank?
        nil
      else
        Faker::Date.between(from: submitted + 1.day, to: Time.zone.today)
      end
    end
    category

    trait :current do
      submitted { Time.zone.today }
    end

    transient do
      author_count { 0 }
    end

    after(:create) do |paper, ev|
      paper.authors = create_list(:author, ev.author_count)
    end
  end
end
