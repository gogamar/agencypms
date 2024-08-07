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

  def update_all?
    user.admin? || user.manager?
  end

  def import_bookings?
    user.admin? || user.manager?
  end

  def organize_cleaning?
    user.admin? || user.manager?
  end

  def cleaning_checkout?
    user.admin? || user.manager?
  end

  def cleaning_checkin?
    user.admin? || user.manager?
  end
end
