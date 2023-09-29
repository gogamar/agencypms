class RatePeriodPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(rate_plan_id: user.company.rate_plans.pluck(:id))
    end
  end

  def show?
    user.company.rate_plans.exists?(record.rate_plan_id)
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
    user.admin? && user.company.rate_plans.exists?(record.rate_plan_id)

  end

  def destroy?
    user.admin? && user.company.rate_plans.exists?(record.rate_plan_id)
  end

end
