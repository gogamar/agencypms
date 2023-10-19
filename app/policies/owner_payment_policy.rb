class OwnerPaymentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.where(owner: user.owners)
    end
  end

  def show?
    user.admin? || user.owners.exists?(record.owner_id)
  end

  def new?
    return create?
  end

  def create?
    user.admin? || user.owners.exists?(record.owner_id)
  end

  def edit?
    return create?
  end

  def update?
    return create?
  end

  def destroy?
    user.admin? || user.owners.exists?(record.owner_id)
  end
end
