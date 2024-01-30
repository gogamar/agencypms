class RatePeriodPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    user.admin?
  end

  def show?
    return true
  end

  def new?
    return create?
  end

  def create?
    user.admin? || user.manager?
  end

  def edit?
    return update?
  end

  def update?
    user.admin? || user.manager?
  end

  def destroy?
    user.admin? || user.manager?
  end
end
