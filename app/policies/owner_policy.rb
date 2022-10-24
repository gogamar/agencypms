class OwnerPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      # scope.all # If users can see all restaurants
      # show only the agreements where rental_id is the same as vacation rentals id that belong to the current user
      scope.includes(:rentals).where('user_id = ?', user.id).references(:rentals)
      # scope.where("name LIKE 't%'") # If users can only see restaurants starting with `t`
    end
  end
  def show?
    # record.rental.user == user
    user.rentals.exists?(record.rental_id)
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
    record.rental.user == user
  end

  def destroy?
    user.rentals.exists?(record.rental_id)
  end
end
