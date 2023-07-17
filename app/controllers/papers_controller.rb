class PapersController < ApplicationController
  def index
    @papers = Paper.all.as_json(
      only: %i[abs arxiv abstract comment category_id id journal_ref pdf submitted revised tags title version],
      include: {
        authors: { only: %i[name arxiv] },
      },
    )
  end
end
