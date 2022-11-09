class Rentaltemplate < ApplicationRecord
  belongs_to :user
  has_many :agreements
  validates :title, presence: true
  validates :language, presence: true
end
