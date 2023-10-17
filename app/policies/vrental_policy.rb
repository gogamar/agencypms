class VrentalPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.where(user: user)
    end
  end

  def total_earnings?
    user.admin?
  end

  def total_city_tax?
    user.admin?
  end

  def download_city_tax?
    user.admin?
  end

  def list_earnings?
    user.admin?
  end

  def fetch_earnings?
    user.admin? || user.vrentals.include?(record)
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

  def delete_year_rates?
    return create?
  end

  def send_rates?
    return show?
  end

  def annual_statement?
    user.admin? || record.user == user
  end

  def get_rates?
    return show?
  end

  def get_bookings?
    return show?
  end

  def upload_dates?
    return create?
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

  def edit_photos?
    return update?
  end

  def update_on_beds?
    return update?
  end

  def send_photos?
    return update?
  end

  def update_from_beds?
    return update?
  end

  def update_vrowner_from_beds?
    return update?
  end
end
