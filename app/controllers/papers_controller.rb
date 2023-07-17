class PapersController < ApplicationController
  def index
    @papers = Paper.limit(60).all.as_json(Paper.inertia_params)
  end
end
