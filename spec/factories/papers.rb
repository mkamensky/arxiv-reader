FactoryBot.define do
  factory :paper do
    arxiv { "MyString" }
    title { "MyString" }
    abstract { "MyText" }
    version { "MyString" }
    submitted { "2023-07-15" }
    revised { "2023-07-15" }
    category { nil }
    comment { "MyText" }
    abs { "MyString" }
    pdf { "MyString" }
    tags { "MyString" }
    journal_ref { "MyString" }
  end
end
