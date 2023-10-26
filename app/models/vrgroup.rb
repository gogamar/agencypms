class Vrgroup < ApplicationRecord
  belongs_to :office
  has_many :vrentals

  has_many_attached :photos
end
