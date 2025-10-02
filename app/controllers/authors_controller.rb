class AuthorsController < ApplicationController
  def show
    render inertia: {
      author: -> {
        author&.inertia_json(
          include: {
            papers: Paper.inertia_params(
              include: { authors: Author.inertia_params },
            ),
          },
        )
      },
    }
  end

  alias_method :author, :object
end
