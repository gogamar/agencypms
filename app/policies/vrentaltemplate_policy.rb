class VrentaltemplatePolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      # scope.where(user: user).or(scope.where(user_id: User.where(admin: true).first.id).where(public: true)) # If users can only see their rentals
      user.admin? ? scope.all : scope.where(user_id: user.id)
    end
  end
  def show?
    record.user == user
  end

  def copy?
    return create?
  end

  def new?
    return create?
  end

  def create?
    return true
  end

  def edit?
    return update?
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user
  end
end
