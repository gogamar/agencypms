class Vrgroup < ApplicationRecord
  belongs_to :office
  has_and_belongs_to_many :vrentals

  has_many_attached :photos

  def photo_ids
    photos.map(&:id)
  end
end
