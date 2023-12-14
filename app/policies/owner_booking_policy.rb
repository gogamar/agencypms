class OwnerBookingPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.manager?
        scope.all
      else
        scope.joins(vrental: :owner).where(owners: { user_id: user.id })
      end
    end
  end

  def show?
    user.admin? || user.manager? || user.vrental_owner(record)
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
    user.admin? || user.manager? || user.vrental_owner(record)
  end

  def show_form?
    user.admin? || user.manager? || user.vrental_owner(record)
  end

  def grant_access?
    user.admin? || user.manager?
  end

  def destroy?
    user.admin? || user.manager?
  end
end
