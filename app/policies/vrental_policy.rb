class VrentalPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.manager?
        scope.all
      elsif user.owner.present?
        scope.where(id: user.owner.vrentals.pluck(:id))
      else
        scope.none
      end
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
    user.admin?
  end

  def dashboard?
    user.admin?
  end

  def get_reviews?
    user.admin?
  end

  def empty_vrentals?
    user.admin?
  end

  def show?
    user.admin? || user.manager? || record.owner == user.owner
  end

  def bookings_on_calendar?
    user.admin? || user.manager? || record.owner == user.owner
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
    user.admin? || user.manager?
  end

  def annual_statement?
    user.admin? || user.manager? || record.owner == user.owner
  end

  def get_rates?
    user.admin? || user.manager?
  end

  def get_bookings?
    user.admin? || user.manager?
  end

  def prevent_gaps?
    user.admin? || user.manager?
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

  def add_bedrooms_bathrooms?
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
    user.admin? || user.manager? || record.owner == user.owner
  end

  def destroy?
    user.admin? || user.manager? || record.owner == user.owner
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
    user.admin?
  end

  def update_owner_from_beds?
    user.admin?
  end

  def import_from_group?
    return update?
  end
end
