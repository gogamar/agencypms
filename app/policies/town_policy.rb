class TownPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.manager?
        scope.all
      elsif user.owner.present? && user.owner.vrentals.any?
        scope.where(id: user.owner.vrentals.pluck(:town_id))
      else
        scope.none
      end
    end
  end

  def show?
    return true
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
