class Post < ApplicationRecord
  belongs_to :category
  belongs_to :user
  belongs_to :feed, optional: true
  has_one_attached :image
  # validate :image_presence

  private

  def image_presence
    errors.add(:image, "must be attached") unless image.attached?
  end
end
