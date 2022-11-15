class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  has_many :profiles, dependent: :destroy
  has_many :tasks
  has_many :vrentals
  has_many :rentals
  has_many :realestates
  has_many :vrowners
  has_many :owners
  has_many :sellers
  has_many :renters
  has_many :buyers
  has_many :vrentaltemplates
  has_many :rentaltemplates
  has_many :rstemplates
  has_many :features
  has_many :vragreements, through: :vrentals
  has_many :agreements, through: :rentals
  has_many :contracts, through: :realestates
  has_many :rates, through: :vrentals
  has_one_attached :photo
  after_create :send_welcome_email

  private

  def send_welcome_email
    UserMailer.with(user: self).welcome.deliver_now
  end
end
