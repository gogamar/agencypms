class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :tasks, dependent: :destroy
  has_many :vrentals, dependent: :destroy
  has_many :vrowners, dependent: :destroy
  has_many :vrentaltemplates, dependent: :destroy
  has_many :features, dependent: :destroy
  has_many :vragreements, through: :vrentals
  has_many :rates, through: :vrentals, dependent: :destroy
  belongs_to :company, optional: true
  has_one :owned_company, class_name: "Company", foreign_key: "user_id"
  has_one_attached :photo, dependent: :destroy
  # after_create :send_welcome_email
  after_create :send_admin_mail
  attribute :approved, :boolean, default: false
  attribute :admin, :boolean, default: false

  def self.send_reset_password_instructions(attributes = {})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    if recoverable.persisted?
      if recoverable.approved?
        recoverable.send_reset_password_instructions
      else
        recoverable.errors.add(:base, :not_approved)
      end
    end
    recoverable
  end

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    approved? ? super : :not_approved
  end

  private

  def send_admin_mail
    AdminMailer.new_user_waiting_for_approval(email).deliver
  end

  def send_welcome_email
    UserMailer.with(user: self).welcome.deliver_now
  end
end
