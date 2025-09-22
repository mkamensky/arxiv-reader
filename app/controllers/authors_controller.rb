class AuthorsController < ApplicationController
  def show
    render inertia: {
      author: -> { author&.inertia_json },
    }
  end

  protected

  def author
    return unless params[:id]

    @author ||= Author.find(params[:id])
  end
end
