class PapersController < ApplicationController
  def show
    render inertia: {
      paper: -> { paper&.inertia_json(include: { authors: Author.inertia_params }) },
    }
  end

  protected

  def paper
    return unless params[:id]

    @paper ||= Paper.find(params[:id])
  end
end
