class ImageUrl < ApplicationRecord
  belongs_to :vrental
  acts_as_list
end
