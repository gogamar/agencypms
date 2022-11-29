class UserPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      # scope.all # If users can see all records
      # show only the records that have the same user_id as current user (user_id: user.id)
      user.admin? ? scope.all : scope.where(user: user) # If users can only see their records
      # scope.where("name LIKE 't%'") # If users can only see records starting with `t`
    end
  end

  def show?
    user.admin? || record.user == user
  end

  def new?
    return create?
  end

  def create?
    user.admin? || record.user == user
  end

  def edit?
    return update?
  end

  def update?
    user.admin? || record.user == user
  end

  def destroy?
    user.admin? || record.user == user
  end
end
