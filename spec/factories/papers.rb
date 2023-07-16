FactoryBot.define do
  factory :paper do
    arxiv { sprintf("%04d.%06d", rand(10000), rand(100000)) }
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
      version == 'v1' || submitted.blank? ? nil : Faker::Date.between(
        from: submitted + 1.day, to: Time.zone.today,
      )
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
