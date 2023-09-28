class RatePlanPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(company_id: user.company)
    end
  end

  def show?
    record.company == user.company
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
    user.owned_company == record.company
  end

  def destroy?
    user.owned_company == record.company
  end
end
