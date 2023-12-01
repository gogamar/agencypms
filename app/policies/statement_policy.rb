class StatementPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.manager?
        scope.all
      elsif user.owner.present?
        scope.where(vrental_id: user.owner.vrentals.pluck(:id))
      end
    end
  end

  def annual_statement?
    user.admin? || user.manager? || user.vrental_owner(record)
  end

  def show?
    user.admin? || user.manager? || user.vrental_owner(record)
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
    user.admin?
  end
end
