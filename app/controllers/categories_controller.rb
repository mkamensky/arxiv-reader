class CategoriesController < ApplicationController
  include Pagy::Backend

  def index
    render_page
  end

  def show
    render_page('show')
  end

  protected

  def category
    return unless params[:id]

    @category ||= Category.find(params[:id])
  end

  def papers
    return unless category

    @pagy, @records = pagy(category.papers)
    @records.as_json(Paper.inertia_params)
  end

  def meta
    @pagy.present? ? pagy_metadata(@pagy) : {}
  end

  def next_page
    meta[:next]
  end

  def render_page(page = 'index')
    render inertia: "categories/#{page}", props: {
      categories: -> { categories },
      category: -> { category&.inertia_json },
      papers: -> { papers },
      nextPage: -> { next_page },
      meta: -> { meta },
    }
  end
end
