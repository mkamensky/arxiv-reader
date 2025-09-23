class ApplicationController < ActionController::Base
  include Authentication
  include InertiaCsrf

  use_inertia_instance_props

  inertia_share auth: -> {
    if authenticated?
      {
        user: Current.user.email,
      }
    end
  }

  inertia_share head: -> { page_head }

  protected

  def page_head
    {}
  end
end
