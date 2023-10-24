class TownPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    return true
  end

  def new?
    return create?
  end

  def create?
    user.admin?
  end

  def edit?
    return update?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end
