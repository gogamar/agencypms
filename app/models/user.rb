class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :profiles, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :vrentals, dependent: :destroy
  has_many :rentals, dependent: :destroy
  has_many :realestates, dependent: :destroy
  has_many :vrowners, dependent: :destroy
  has_many :owners, dependent: :destroy
  has_many :sellers, dependent: :destroy
  has_many :renters, dependent: :destroy
  has_many :buyers, dependent: :destroy
  has_many :vrentaltemplates, dependent: :destroy
  has_many :rentaltemplates, dependent: :destroy
  has_many :rstemplates, dependent: :destroy
  has_many :features, dependent: :destroy
  has_many :vragreements, through: :vrentals
  has_many :agreements, through: :rentals
  has_many :contracts, through: :realestates, dependent: :destroy
  has_many :rates, through: :vrentals, dependent: :destroy
  has_one_attached :photo, dependent: :destroy
  after_create :send_welcome_email

  private

  def send_welcome_email
    UserMailer.with(user: self).welcome.deliver_now
  end
end
