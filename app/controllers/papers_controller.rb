class PapersController < ApplicationController
  include CursorPaginatable

  def index
    out, cursor =
      paginate_with_cursor(spapers, by: :id, before: params[:cursor])
    papers = InertiaRails.merge { out&.map { paper_json(it) } }
    render inertia: {
      papers:,
      cursor:,
      total: -> { spapers.count },
    }
  end

  def show
    render inertia: {
      paper: -> { paper_json },
    }
  end

  protected

  def paper
    return unless params[:id]

    @paper ||= Paper.find(params[:id])
  end

  alias_method :object, :paper

  def q
    params[:q]
  end

  def spapers
    return if q.blank?

    @spapers ||= Paper.search_all(q)
  end

  def paper_json(ppr = paper)
    ppr&.inertia_json(include: { authors: Author.inertia_params })
  end

  def index_page_title
    "Search results: #{q}"
  end
end
