class Company < ApplicationRecord
  belongs_to :admin, class_name: "User", foreign_key: "user_id"
  has_many :users
  has_many :offices
  has_many :vrentaltemplates
  has_many :features
  has_many :rate_plans
  has_one_attached :logo
  # validate :user_can_create_only_one_company, on: :create

  def available_vrentals(checkin, checkout, guests, prop_ids)
    available_vrentals = []
    offices.each do |office|
      result = office.get_availability_from_beds(checkin, checkout, guests, prop_ids)
      puts "these are the available_vrentals in #{office.name}: #{result}"
      available_vrentals.concat(result)
    end
    puts "these are the available_vrentals in both offices: #{available_vrentals}"
    available_vrentals
  end

  def future_available_dates
    latest_rate = Rate.order(lastnight: :desc).first
    from_date = Date.today
    to_date = latest_rate ? latest_rate.lastnight + 1.day : Date.today.next_year

    return [{ from: from_date, to: to_date }]
  end

  private

  # def user_can_create_only_one_company
  #   if current_user&.admin? && current_user.owned_company.present?
  #     errors.add(:base, "Només es pot crear una empresa per usuari.")
  #   end
  # end
end
