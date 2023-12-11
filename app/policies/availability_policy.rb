class AvailabilityPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all if user.admin? || user.manager?
    end
  end

  def new?
    return create?
  end

  def create?
    return true
  end

  def edit?
    return update?
  end

  def update?
    user.admin? || user.vrental_manager(record) || user.vrental_owner(record)
  end

  def destroy?
    user.admin?
  end
end
