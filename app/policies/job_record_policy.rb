class JobRecordPolicy < ApplicationPolicy
  def create?
    user.admin? || user.manager?
  end

  def update?
    user.admin? || user.manager?
  end

  def destroy?
    user.admin?
  end

  def status?
    user.admin? || user.manager?
  end
end
