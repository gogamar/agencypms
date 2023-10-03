class ImageUrl < ApplicationRecord
  belongs_to :vrental
  # validates :url, presence: true
end
