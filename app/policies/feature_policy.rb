class FeaturePolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      # scope.all # If users can see all features
      # show only the agreements where vrental_id is the same as vacation rentals id that belong to the current user
      scope.where(user: user)
      # scope.where(vrental_id: user.features.select(:vrental_id)) # If users can only see the features of their vacation rentals
      # scope.where("name LIKE 't%'") # If users can only see features starting with `t`
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
