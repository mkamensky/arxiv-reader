#[Paper, Author].each(&:destroy_all)

#Rails.logger = Logger.new(Rails.env.local? ? $stdout : 'log/arxiv_update.log')
Rails.logger = Logger.new($stdout)

math = Subject.find('math')
papers = math.refresh_from_arxiv(verbose: true)
if papers.blank?
  Rails.logger.info 'Added no new papers'
else
  Rails.logger.info "Added #{papers.count} papers, starting with #{papers.first.submitted}"
end
