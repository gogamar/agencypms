class Comtype < ApplicationRecord
  validates :company_type, uniqueness: true
  belongs_to :user
  has_many :profiles
end
