class CouponPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.where(office_id: user.offices.pluck(:office_id))
    end
  end

  def show?
    user.admin? || user.offices.exists?(record.office_id)
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
    user.admin? || user.offices.exists?(record.office_id)
  end

  def apply_to_all?
    user.admin? || user.offices.exists?(record.office_id)
  end

  def destroy?
    user.admin? || user.offices.exists?(record.office_id)
  end
end
