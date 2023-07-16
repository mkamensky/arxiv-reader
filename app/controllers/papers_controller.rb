class PapersController < ApplicationController
  def index
    @papers = Paper.all
  end
end
