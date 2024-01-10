class ImageUrl < ApplicationRecord
  belongs_to :vrental
  acts_as_list

  def is_group_photo?
    vrgroup_photo_ids = []
    vrgroups.each do |vrgroup|
      vrgroup_photo_ids.merge(vrgroup.photo_ids)
    end
    vrgroup_photo_ids.include?(photo_id)
  end
end
