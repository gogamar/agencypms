class VrentalPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      # scope.all # If users can see all rentals
      # show only the rentals that have the same user_id as current user (user_id: user.id)
      scope.where(user: user) # If users can only see their rentals
      # scope.where("name LIKE 't%'") # If users can only see rentals starting with `t`
    end
  end
  def show?
    record.user == user
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
    record.user == user
  end

  def destroy?
    record.user == user
  end
end
