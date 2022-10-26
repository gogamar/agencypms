class Rentaltemplate < ApplicationRecord
  has_many :agreements
  belongs_to :user
end
