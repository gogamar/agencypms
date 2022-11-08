class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :profiles, dependent: :destroy
  has_many :tasks
  has_many :vrentals
  has_many :rentals
  has_many :vrowners
  has_many :owners
  has_many :renters
  has_many :vrentaltemplates
  has_many :rentaltemplates
  has_many :features
  has_many :vragreements, through: :vrentals
  has_many :agreements, through: :rentals
  has_many :rates, through: :vrentals
  has_one_attached :photo
end
