class ContractPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(realestate_id: user.contracts.select(:realestate_id))
    end
  end
  def show?
    # record.realestate.user == user
    user.realestates.exists?(record.realestate_id)
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
    record.realestate.user == user
  end

  def destroy?
    user.realestates.exists?(record.realestate_id)
  end
end
