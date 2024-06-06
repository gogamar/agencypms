class Feature < ApplicationRecord
  has_and_belongs_to_many :vrentals
  belongs_to :company
  # validates :name, uniqueness: true

  FEATURES = [
    "kitchen", "washer", "oven", "toaster", "microwave", "hair_dryer",
    "iron_board", "garden", "wifi", "refrigerator", "grill",
    "sea_view", "dishwasher", "pool_private", "pets_considered",
    "air_conditioning", "freezer", "elevator", "beach_view",
    "private_yard", "smoke_detector", "pets_not_allowed", "balcony",
    "parking_included", "parking_possible", "deck_patio_uncovered",
    "kettle", "beach_front", "pool", "coffee_maker", "roof_terrace",
    "tv", "fireplace", "ceiling_fan", "monument_view", "dryer", "heating"
  ]
end
