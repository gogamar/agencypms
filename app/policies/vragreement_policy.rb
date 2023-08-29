class VragreementPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(vrental_id: user.vragreements.select(:vrental_id))
    end
  end
  def show?
    user.vrentals.exists?(record.vrental_id)
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

  def update?
    record.vrental.user == user
  end

  def destroy?
    user.vrentals.exists?(record.vrental_id)
  end
end
