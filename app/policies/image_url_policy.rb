class ImageUrlPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    true
  end

  def new?
    user.admin? || user.manager? || user.vrental_owner(record)
  end

  def create?
    return new?
  end

  def edit?
    return update?
  end

  def update?
    user.admin? || user.manager? || user.vrental_owner(record)
  end

  def destroy?
    user.admin? || user.manager? || user.vrental_owner(record)
  end

  def move?
    user.admin? || user.manager? || user.vrental_owner(record)
  end
end
