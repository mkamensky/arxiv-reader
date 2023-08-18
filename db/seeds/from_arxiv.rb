#[Paper, Author].each(&:destroy_all)

math = Subject.find('math')
math.refresh_from_arxiv(verbose: true)
