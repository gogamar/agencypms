class VrentalPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      # scope.all # If users can see all rentals
      # show only the rentals that have the same user_id as current user (user_id: user.id)
      # if user.admin?
      #   scope.all
      # else
        # scope.includes(:vrowner).where(user: user)
        scope.where(user: user)
        # scope.joins(:vrowner).where( user_id: user.id )
      # scope.where(user:) # If users can only see their rentals
      # scope.where("name LIKE 't%'") # If users can only see rentals starting with `t`
    end
  end

  # def index?
  #   user.admin?
  # end

  # def list?
  #   # allow to see the vrowners of these vrentals
  #   user.vrentals.exists?(record.vrowner_id)
  # end

  def show?
    record.user == user
  end

  def copy?
    return create?
  end

  def copy_rates?
    return create?
  end

  def delete_rates?
    return create?
  end

  def send_rates?
    return show?
  end

  def export_beds?
    return show?
  end

  def update_beds?
    return show?
  end

  def get_rates?
    return show?
  end

  def get_bookings?
    return show?
  end

  def new?
    return create?
  end

  def add_vrowner?
    return create?
  end

  def add_features?
    return create?
  end

  def create?
    return true
  end

  def edit?
    return update?
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user
  end
end
