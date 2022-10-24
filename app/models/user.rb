class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :profiles, dependent: :destroy
  has_many :vrentals
  has_many :vrentaltemplates
  has_many :vrowners, through: :vrentals
  has_many :vragreements, through: :vrentals
  has_many :rates, through: :vrentals
  has_many :features
  has_one_attached :photo
end
