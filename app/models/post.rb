class Post < ApplicationRecord
  belongs_to :category
  belongs_to :user, optional: true
  belongs_to :feed, optional: true
  has_one_attached :image
  # validate :image_presence

  private

  def image_presence
    unless image_url.present? || image.attached?
      errors.add(:image, "must be attached or image_url must be present")
    end
  end
end
