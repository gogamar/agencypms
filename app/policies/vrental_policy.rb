class VrentalPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # scope.all # If users can see all records
      # show only the records that have the same user_id as current user (user_id: user.id)
      user.admin? ? scope.all : scope.where(user: user) # If users can only see their records
      # scope.where("name LIKE 't%'") # If users can only see records starting with `t`
    end
  end

  # def index?
  #   user.admin?
  # end

  # def list?
  #   # allow to see the vrowners of these vrentals
  #   user.vrentals.exists?(record.vrowner_id)
  # end

  def total_earnings?
    user.admin?
  end

  def list_earnings?
    user.admin?
  end

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
