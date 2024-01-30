class RatePlan < ApplicationRecord
  belongs_to :company
  has_many :vrentals
  has_many :rate_periods, dependent: :destroy
  validates_presence_of :start, :end, :gen_arrival, :gen_min, :company, :name
end
