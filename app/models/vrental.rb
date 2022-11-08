class Vrental < ApplicationRecord
  belongs_to :user
  belongs_to :vrowner, optional: true
  has_many :vragreements, dependent: :destroy
  has_many :rates, dependent: :destroy
  has_and_belongs_to_many :features
  validates :name, presence: true
  # validates :name, uniqueness: {
    # object = person object being validated
    # data = { model: "Person", attribute: "Username", value: <username> }
  #   message: ->(object, data) do
  #     "#{object.name} ja existeix!"
  #   end
  # }
  validates :status, presence: true


  def available_dates
    next_rate = rates.where('firstnight > ?', Date.today).order(:firstnight).first
    Date.tomorrow..next_rate.firstnight
  end

  def unavailable_dates
    rates.pluck(:firstnight, :lastnight).map do |range|
      { from: range[0], to: range[1] }
    end
  end

  # def default_checkin
  # find the last rate of this vrental
  # take its lastnight
  # set the default value for the new rate as lastnight + 1 day
  #
  #   all_rates_one_year = rates.where(:firstnight.year).order(:firstnight).last.lastnight + 1.day
  # end

  def default_checkin
    last_rate = rates.find_by(lastnight: rates.maximum('lastnight'))
    last_rate.lastnight + 1.day
    # may have to be: rates.where(lastnight: vrental.rates.maximum('lastnight'))
  end

  def default_checkin_two
    last_rate_two = rates.where(lastnight: rates.select('MAX(lastnight)'))
    last_rate_two.lastnight + 1.day
  end
end
