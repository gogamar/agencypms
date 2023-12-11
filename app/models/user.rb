class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  has_one :owner, dependent: :nullify
  has_one :tourist, dependent: :nullify
  has_many :tasks, dependent: :destroy
  has_many :owned_companies, class_name: "Company", foreign_key: "user_id"
  belongs_to :company, optional: true
  belongs_to :office, optional: true
  has_one_attached :photo, dependent: :destroy

  attr_accessor :created_by_admin

  after_create :send_admin_mail
  enum role: [ "admin", "manager" ]

  def vrental_manager(this_record)
    manager? && office.present? && office.vrentals.exists?(this_record.vrental_id)
  end

  def vrental_owner(this_record)
    owner.present? && owner.vrentals.exists?(this_record.vrental_id)
  end

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


  def send_reset_password_instructions_with_locale(lang)
    I18n.with_locale(lang) do
      send_reset_password_instructions
    end
  end

  def send_confirmation_instructions_with_locale(lang)
    I18n.with_locale(lang) do
      send_confirmation_instructions
    end
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
end
