class Vrental < ApplicationRecord
  belongs_to :user
  belongs_to :vrowner, optional: true
  has_many :vragreements, dependent: :destroy
  has_many :rates, dependent: :destroy
  has_and_belongs_to_many :features
  validates :name, presence: true
  validates :status, presence: true

  def unavailable_dates
    rates.pluck(:firstnight, :lastnight).map do |range|
      { from: range[0], to: range[1] }
    end
  end

  def copy_rates_to_next_year
    #for some reason this method doesn't work the same locally
    easter_season_firstnight = {
    2022 => Date.new(2022,4,2),
    2023 => Date.new(2023,4,1),
    2024 => Date.new(2024,3,23),
    2025 => Date.new(2025,4,12),
    2026 => Date.new(2026,3,28),
    2027 => Date.new(2027,3,20),
    2028 => Date.new(2028,4,8)
    }
    current_rates = rates.where("DATE_PART('year', firstnight) = ?", Date.today.year)
    current_rates.each do |existingrate|
    next_year = existingrate.firstnight.year + 1
      # if Easter Rate is 10 days and the rate doesn't already exist for the next year
      if easter_season_firstnight.value?(existingrate.firstnight) && (existingrate.lastnight - existingrate.firstnight).to_i == 10 && !rates.where(firstnight: easter_season_firstnight[next_year]).exists?
        Rate.create!(
          firstnight: easter_season_firstnight[next_year],
          lastnight: easter_season_firstnight[next_year] + 10,
          pricenight: existingrate.pricenight,
          priceweek: existingrate.priceweek,
          beds_room_id: existingrate.beds_room_id,
          vrental_id: existingrate.vrental_id,
          min_stay: existingrate.min_stay,
          arrival_day: existingrate.arrival_day
        )
      # if Easter rate is longer than 10 days and the rate doesn't already exist for the next year
      elsif easter_season_firstnight.value?(existingrate.firstnight) && (existingrate.lastnight - existingrate.firstnight).to_i > 10 && !rates.where(firstnight: easter_season_firstnight[next_year]).exists?
        Rate.create!(
          firstnight: easter_season_firstnight[next_year],
          lastnight: existingrate.lastnight + 364,
          pricenight: existingrate.pricenight,
          priceweek: existingrate.priceweek,
          beds_room_id: existingrate.beds_room_id,
          vrental_id: existingrate.vrental_id,
          min_stay: existingrate.min_stay,
          arrival_day: existingrate.arrival_day
        )
      # if it's Before Easter rate and the rate doesn't already exist for the next year
      elsif easter_season_firstnight.value?(existingrate.lastnight + 1) && !rates.where(lastnight: easter_season_firstnight[next_year] - 1).exists?
        Rate.create!(
          firstnight: existingrate.firstnight + 364,
          lastnight: easter_season_firstnight[next_year] - 1,
          pricenight: existingrate.pricenight,
          priceweek: existingrate.priceweek,
          beds_room_id: existingrate.beds_room_id,
          vrental_id: existingrate.vrental_id,
          min_stay: existingrate.min_stay,
          arrival_day: existingrate.arrival_day
        )
      elsif !rates.where(firstnight: existingrate.firstnight + 364).present?
        Rate.create!(
          firstnight: existingrate.firstnight + 364,
          lastnight: existingrate.lastnight + 364,
          pricenight: existingrate.pricenight,
          priceweek: existingrate.priceweek,
          beds_room_id: existingrate.beds_room_id,
          vrental_id: existingrate.vrental_id,
          min_stay: existingrate.min_stay,
          arrival_day: existingrate.arrival_day
        )
      # else
      #   return
      end
    end
  end

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
