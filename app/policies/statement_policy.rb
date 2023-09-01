class StatementPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(vrental_id: user.vrentals.pluck(:id))
    end
  end

  def show?
    user.vrentals.exists?(record.vrental_id)
  end

  def new?
    return create?
  end

  def create?
    return true
  end

  def add_earnings?
    return update?
  end

  def add_expenses?
    return update?
  end

  def edit?
    return update?
  end

  def update?
    record.vrental.user == user
  end

  def destroy?
    user.vrentals.exists?(record.vrental_id)
  end
end
