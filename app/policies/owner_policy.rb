class OwnerPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.admin? || user.manager? ? scope.all : scope.where(user: user)
    end
  end

  def show?
    user.admin? || user.manager? || record.user == user
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
    user.admin? || user.manager? || record.user == user
  end

  def grant_access?
    user.admin? || user.manager?
  end

  def remove_access?
    user.admin? || user.manager?
  end

  def send_access_email?
    user.admin? || user.manager?
  end

  def destroy?
    user.admin? || user.manager?
  end
end
