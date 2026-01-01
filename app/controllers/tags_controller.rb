class TagsController < ApplicationController
  before_action :require_authentication
  rate_limit to: 10, within: 3.minutes, with: -> {
    flash.alert = 'Try again later'
    redir_back
  }

  def show
    render inertia: {
      model_name => -> { object&.inertia_json(**inertia_params) },
    }
  end

  def create
    obj = scope.create(valid_params)
    if obj.persisted?
      flash.notice = "Created #{model_name} #{obj}"
      redir_back
    else
      redir_back(errors: obj.errors)
    end
  end

  def update
    if object&.update(valid_params)
      redir_back
    else
      redir_back(errors: object&.errors)
    end
  end

  def destroy
    if object.destroy
      redir_back
    else
      redir_back(errors: object&.errors)
    end
  end

  protected

  def scope
    current_user&.tags
  end

  def valid_params
    params.expect(tag: %i[title val color])
  end

  alias_method :tag, :object

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
