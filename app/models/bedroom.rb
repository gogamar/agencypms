class Bedroom < ApplicationRecord
  belongs_to :vrental
  has_many :beds, dependent: :destroy
end
