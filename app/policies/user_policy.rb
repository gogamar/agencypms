class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all if user.admin? || user.manager?
    end
  end

  def create?
    user.admin? || user.manager?
  end

  def update?
    user.admin? || user.manager?
  end

  def destroy?
    user.admin?
  end
end
