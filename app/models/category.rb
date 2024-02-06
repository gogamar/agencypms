class Category < ApplicationRecord
  has_many :posts
  has_many :feeds, dependent: :nullify
  validates :name_ca, :name_es, :name_en, :name_fr, presence: true
end
