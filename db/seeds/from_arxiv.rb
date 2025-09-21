#[Paper, Author].each(&:destroy_all)

math = Subject.find('math')
papers = math.refresh_from_arxiv(verbose: true)
# rubocop: disable Rails/Output
if papers.blank?
  puts 'Added no new papers'
else
  puts "Added #{papers.count} papers, starting with #{papers.first.submitted}"
end
# rubocop: enable Rails/Output
