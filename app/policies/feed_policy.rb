class FeedPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all if user.admin?
    end
  end

  def show?
    user.admin?
  end

  def new?
    return create?
  end

  def create?
    user.admin?
  end

  def edit?
    return update?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end
