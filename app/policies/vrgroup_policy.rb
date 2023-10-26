class VrgroupPolicy < ApplicationPolicy
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
    user.office.present? ? record.office == user.office : user.admin? && user.owned_company == record.office.company
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
    user.office.present? ? record.office == user.office : user.admin? && user.owned_company == record.office.company
  end

  def destroy?
    user.admin? && user.owned_company == record.office.company
  end
end
