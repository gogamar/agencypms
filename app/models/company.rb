class Company < ApplicationRecord
  belongs_to :admin, class_name: "User", foreign_key: "user_id"
  has_many :users
  has_many :offices
  has_many :rate_plans

  # validate :user_can_create_only_one_company, on: :create

  private

  # def user_can_create_only_one_company
  #   if current_user&.admin? && current_user.owned_company.present?
  #     errors.add(:base, "Només es pot crear una empresa per usuari.")
  #   end
  # end
end
