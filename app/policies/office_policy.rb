class OfficePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.where(company_id: user.company_id)
    end
  end

  def show?
    return true
  end

  def home?
    return true
  end

  def copy?
    return create?
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

  def import_properties?
    user.admin?
  end

  def destroy_all_properties?
    user.admin?
  end
end
