class AvailabilityRulePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(vrental_id: user.vrentals.pluck(:id))
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
    record.vrental.user == user
  end

  def destroy?
    user.admin? || user.vrentals.exists?(record.vrental_id)
  end
end
