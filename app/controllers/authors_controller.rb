class AuthorsController < ApplicationController
  def index
    authors = sauthors&.map { it.inertia_json(**inertia_params) }
    render inertia: { authors: }
  end

  def show
    render inertia: {
      author: -> { author&.inertia_json(**inertia_params) },
    }
  end

  alias_method :author, :object

  protected

  def q
    @q ||= params[:q].presence && LaTeX.decode(params[:q])
  end

  def sauthors
    return if q.blank?

    @sauthors ||= policy_scope(Author.search_all(q))
  end

  def index_page_title
    "Search results: #{q}"
  end

  def inertia_params
    {
      include: {
        papers: Paper.inertia_params(
          include: { authors: Author.inertia_params },
        ),
      },
    }
  end
end
