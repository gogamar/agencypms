class BookingPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.manager?
        scope.all
      elsif user.tourist.present?
        scope.where(tourist_id: user.tourist.id)
      end
    end
  end

  def show?
    user.admin? || user.vrental_manager(record)
  end

  def show_booking?
    return show?
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
    user.admin? || user.vrental_manager(record)
  end

  def destroy?
    user.admin?
  end
end
