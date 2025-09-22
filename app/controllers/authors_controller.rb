class AuthorsController < ApplicationController
  def show
    render inertia: {
      author: -> { author&.inertia_json(include: { papers: Paper.inertia_params }) },
    }
  end

  protected

  def author
    return unless params[:id]

    @author ||= Author.find(params[:id])
  end
end
