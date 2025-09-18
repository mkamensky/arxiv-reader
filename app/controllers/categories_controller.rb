class CategoriesController < ApplicationController
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

  def date
    Date.parse(params[:date])
  rescue TypeError
    Time.zone.today
  end

  def papers
    return unless category

    @records = category.papers.where(submitted: date)
    #if @records.blank?
    #  category.refresh_from_arxiv(from: date, until: date, verbose: true)
    #  @records = category.papers.where(submitted: date)
    #end
    @records.as_json(Paper.inertia_params)
  end

  def render_page(page = 'index')
    render inertia: "categories/#{page}", props: {
      categories: -> { categories },
      category: -> { category&.inertia_json },
      papers: -> { papers },
      date: -> { date },
    }
  end
end
