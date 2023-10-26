class ImageUrl < ApplicationRecord
  belongs_to :vrental
  acts_as_list

  def is_group_photo?
    vrgroup = vrental.vrgroup
    return if vrgroup.nil?
    group_photos_ids = vrgroup.photos.pluck(:id)
    group_photos_ids.include?(photo_id)
  end
end
