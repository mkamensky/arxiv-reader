# frozen_string_literal: true

class SessionPolicy < ApplicationPolicy
  def show?
    user == record&.user
  end

  def update?
    user == record&.user
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
