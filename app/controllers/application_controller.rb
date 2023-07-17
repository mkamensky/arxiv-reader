class ApplicationController < ActionController::Base
  include InertiaCsrf
  use_inertia_instance_props

  inertia_share auth: -> {
    if user_signed_in?
      {
        user: current_user.email,
      }
    end
  }

  inertia_share head: -> {
    page_head
  }
  inertia_share categories: -> { categories }

  protected

  def page_head
    {}
  end

  SUBJECT = Subject.find('math')
  private_constant :SUBJECT

  def categories
    @categories ||= SUBJECT.categories.as_json(Category.inertia_params)
  end
end
