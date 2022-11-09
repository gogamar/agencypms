class Rentaltemplate < ApplicationRecord
  has_many :agreements
  belongs_to :user
  validates :title, presence: true
  validates :language, presence: true
end
