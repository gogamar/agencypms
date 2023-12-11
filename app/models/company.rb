class Company < ApplicationRecord
  belongs_to :admin, class_name: "User", foreign_key: "user_id"
  has_many :users
  has_many :offices
  has_many :vrentals, through: :offices
  has_many :vrentaltemplates
  has_many :vragreements
  has_many :statements
  has_many :invoices
  has_many :features
  has_many :rate_plans
  has_one_attached :logo
  validate :only_one_active_company
  validates :name, presence: true, uniqueness: true
  validates :language, presence: true

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

  def only_one_active_company
    if active? && Company.where(active: true).where.not(id: id).exists?
      errors.add(:active, "Només pot haver una empresa activa")
    end
  end
end
