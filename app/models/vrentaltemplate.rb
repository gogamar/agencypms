class Vrentaltemplate < ApplicationRecord
  has_many :vragreements
  belongs_to :user
  validates :name, presence: true
  validates :name, uniqueness: true
end
