class TagPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user == record.user
  end

  def update?
    user == record.user
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      user.tags.scope
    end

    protected

    attr_reader :user, :scope
  end
end
