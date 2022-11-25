class ComtypePolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      # scope.all # If users can see all records
      # show only the records that have the same user_id as current user (user_id: user.id)
      scope.where(user: user).or(scope.where(user_id: User.where(admin: true).first.id)) # If users can only see their records
      # scope.where("name LIKE 't%'") # If users can only see records starting with `t`
    end
  end

  def new?
    return create?
  end

  def create?
    user.admin?
  end

  def edit?
    return update?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end
