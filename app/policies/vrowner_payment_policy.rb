class VrownerPaymentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.where(vrowner: user.vrowners)
    end
  end

  def show?
    user.admin? || user.vrowners.exists?(record.vrowner_id)
  end

  def new?
    return create?
  end

  def create?
    user.admin? || user.vrowners.exists?(record.vrowner_id)
  end

  def edit?
    return create?
  end

  def update?
    return create?
  end

  def destroy?
    user.admin? || user.vrowners.exists?(record.vrowner_id)
  end
end
