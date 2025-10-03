class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  include InertiaCsrf

  protect_from_forgery with: :null_session

  before_action :auth
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: %i[index]
  rescue_from ActionController::InvalidAuthenticityToken,
              with: :inertia_page_expired_error

  def index
  end

  #use_inertia_instance_props

  inertia_share auth: -> {
    { user: current_user&.inertia_json(**user_inertia_params) }
  }

  inertia_share head: -> { page_head }

  inertia_share flash: -> { flash.to_hash }

  protected

  def page_head
    { title: page_title }
  end

  def object
    @object ||= model.find(params[:id]) if params[:id]
  end

  def model
    @model ||= controller_name.classify.constantize
  end

  def current_user
    cur_session&.user
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

  def auth_item
    %w[show update destroy].include?(action_name) ? object : model
  end

  def auth
    if auth_item
      authorize auth_item
    else
      skip_authorization
    end
  end

  def user_inertia_params
    {
      include: {
        bpapers: Paper.inertia_params(
          include: { authors: Author.inertia_params },
        ),
        fauthors: Author.inertia_params,
      },
    }
  end

  def inertia_page_expired_error
    redirect_back_or_to('/', allow_other_host: false, notice: "The page expired, please try again.")
  end
end
