require 'factory_bot_rails'
require 'faker'

FactoryBot.create_list(:author, 15)
cats = Category.all
authors = Author.all
30.times do
  paper = FactoryBot.create(:paper, category: cats.sample)
  paper.secondaries << cats.sample([0, 1, 2, 3].sample)
  paper.authors << authors.sample([1, 2, 3, 4].sample)
  puts <<EOF
Created paper '#{paper.title}':
  Category: #{paper.category.title}
  Secondary categories: #{paper.secondaries.map(&:arxiv).join(', ')}
  Authors: #{paper.authors.map(&:name).join(', ')}
EOF
end

