class Rstemplate < ApplicationRecord
  belongs_to :user
  has_many :contracts
  validates :title, presence: true
  validates :language, presence: true
end
