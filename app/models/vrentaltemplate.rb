class Vrentaltemplate < ApplicationRecord
  has_many :vragreements
  belongs_to :user
  validates :title, presence: true
  validates :title, uniqueness: true
end
