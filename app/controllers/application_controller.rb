class ApplicationController < ActionController::Base
  include Authentication
  include InertiaCsrf

  use_inertia_instance_props

  inertia_share auth: -> {
    {
      user: Current.user&.inertia_json,
    }
  }

  inertia_share head: -> { page_head }

  protected

  def page_head
    {}
  end
end
