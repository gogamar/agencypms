class Tourist < ApplicationRecord
  belongs_to :user, optional: true
  has_many :bookings, dependent: :nullify
end
