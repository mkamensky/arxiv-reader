# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    user == record
  end

  def update?
    user == record
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.none
    end

    protected

    attr_reader :user, :scope
  end
end
