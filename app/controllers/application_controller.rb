class ApplicationController < ActionController::Base
  include Authentication
  include InertiaCsrf

  use_inertia_instance_props

  inertia_share auth: -> {
    {
      user: Current.user&.inertia_json(
        include: {
          bpapers: Paper.inertia_params(
            include: { authors: Author.inertia_params },
          ),
          fauthors: Author.inertia_params,
        },
      ),
    }
  }

  inertia_share head: -> { page_head }

  inertia_share flash: -> { flash.to_hash }

  protected

  def page_head
    { title: page_title }
  end

  def object
  end

  def index_page_title
    'ArxivReader'
  end

  def page_title
    object ? object.label : index_page_title
  end

  def redir_back(**opts)
    redirect_back_or_to after_authentication_url, inertia: opts
  end
end
