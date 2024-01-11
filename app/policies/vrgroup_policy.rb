class VrgroupPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all if user.admin? || user.manager?
    end
  end

  def show?
    user.admin? || user.manager?
  end

  def copy?
    return create?
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

  def prevent_gaps?
    return update?
  end

  def update?
    user.admin? || user.manager?
  end

  def destroy?
    user.admin? && user.owned_company == record.office.company
  end
end
