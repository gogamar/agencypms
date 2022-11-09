class ContractPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      # scope.all # If users can see all restaurants
      # show only the contracts where realestate_id is the same as vacation realestates id that belong to the current user
      scope.where(realestate_id: user.contracts.select(:realestate_id)) # If users can only see their restaurants
      # scope.where("name LIKE 't%'") # If users can only see restaurants starting with `t`
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
