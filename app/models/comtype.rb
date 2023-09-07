class Comtype < ApplicationRecord
  validates :company_type, uniqueness: true
  belongs_to :user
end
