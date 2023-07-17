class CategoriesController < ApplicationController
  def index
    render inertia: 'categories/index', props: {
      categories:,
      category: category&.inertia_json,
      papers:,
    }
  end

  def show
    render inertia: 'categories/index', props: {
      categories:,
      category: category&.inertia_json,
      papers:,
    }
  end

  protected

  SUBJECT = Subject.find('math')
  private_constant :SUBJECT

  def categories
    @categories ||= SUBJECT.categories.as_json(Category.inertia_params)
  end

  def category
    return unless params[:id]

    @category ||= Category.find(params[:id])
  end

  def papers
    return unless category

    @papers ||= category.papers.limit(60).as_json(Paper.inertia_params)
  end
end
