class OfficePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
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

  def get_reviews_from_airbnb?
    user.admin? || user.manager?
  end

  def destroy_all_properties?
    user.admin?
  end

  def create_or_update_schedules?
    user.admin? || user.manager?
  end
end
