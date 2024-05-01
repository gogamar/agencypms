class CleaningCompany < ApplicationRecord
  has_many :vrentals
  belongs_to :office
end
