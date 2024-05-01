class CleaningCompanyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all if user.admin? || user.manager?
    end
  end

  def show?
    user.admin? || user.manager?
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

  def apply_to_all?
    user.admin? || user.manager?
  end

  def destroy?
    user.admin? || user.manager?
  end
end
