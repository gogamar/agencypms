class Bedroom < ApplicationRecord
  belongs_to :vrental
  has_many :beds, dependent: :destroy
  accepts_nested_attributes_for :beds,
                              allow_destroy: true,
                              reject_if: proc { |att| att['bed_type'].blank? }

  BEDROOM_TYPES = ["BEDROOM", "BEDROOM_LIVING_SLEEPING_COMBO"]
end
