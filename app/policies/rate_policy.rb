class RatePolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      # scope.all # If users can see all rates
      # show only the agreements where vrental_id is the same as vacation rentals id that belong to the current user
      scope.where(vrental_id: user.rates.select(:vrental_id)) # If users can only see the rates of their vacation rentals
      # scope.where("name LIKE 't%'") # If users can only see rates starting with `t`
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
