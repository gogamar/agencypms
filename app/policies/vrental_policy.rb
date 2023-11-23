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

  def dashboard?
    user.admin?
  end

  def empty_vrentals?
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

  def copy_images?
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

  def get_availabilities_from_beds?
    user.admin? || record.user == user
  end

  def annual_statement?
    user.admin? || record.user == user
  end

  def get_rates?
    return update?
  end

  def get_bookings?
    return update?
  end

  def prevent_gaps?
    return update?
  end

  def upload_dates?
    return create?
  end

  def new?
    return create?
  end

  def add_owner?
    return create?
  end

  def add_features?
    return create?
  end

  def add_booking_conditions?
    return create?
  end

  def add_descriptions?
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

  def add_photos?
    return update?
  end

  def update_on_beds?
    return update?
  end

  def send_photos?
    return update?
  end

  def import_photos?
    return update?
  end

  def update_from_beds?
    return update?
  end

  def update_owner_from_beds?
    return update?
  end

  def import_from_group?
    return update?
  end

end
