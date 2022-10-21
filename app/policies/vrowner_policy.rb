class VrownerPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      # scope.all # If users can see all restaurants
      # show only the agreements where vrental_id is the same as vacation rentals id that belong to the current user
      scope.includes(:vrentals).where('user_id = ?', user.id).references(:vrentals)
      # scope.where("name LIKE 't%'") # If users can only see restaurants starting with `t`
    end
  end
  def show?
    # record.vrental.user == user
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
