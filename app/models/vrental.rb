class Vrental < ApplicationRecord
  belongs_to :user
  belongs_to :vrowner, optional: true
  has_many :vragreements, dependent: :destroy
  has_many :rates, dependent: :destroy
  has_and_belongs_to_many :features
  validates :name, presence: true
  validates :status, presence: true
  validates :name, uniqueness: true

  def available_dates
    next_rate = rates.where('firstnight > ?', Date.today).order(:firstnight).first
    Date.tomorrow..next_rate.firstnight
  end

  # def next_checkin
  #   all_rates_one_year = rates.where(:firstnight.year).order(:firstnight).last.lastnight + 1.day
  # end
end
