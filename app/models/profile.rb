class Profile < ApplicationRecord
  belongs_to :user
  # has_many :agremeents, dependent: :destroy
  has_one_attached :photo
  validates :businessname, presence: true, length: { minimum: 3 }
  validates :companytype, presence: true, length: { minimum: 3 }
end
