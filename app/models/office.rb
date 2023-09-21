class Office < ApplicationRecord
  belongs_to :company
  has_many :vrentals
  validates :name, presence: true, uniqueness: { scope: :company_id }
end
