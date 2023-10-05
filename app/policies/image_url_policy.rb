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
    user.admin? || user.vrentals.include?(record.vrental)
  end

  def create?
    return new?
  end

  def edit?
    return update?
  end

  def update?
    user.admin? || user.vrentals.include?(record.vrental)
  end

  def destroy?
    user.admin? || user.vrentals.include?(record.vrental)
  end

  def move?
    user.admin? || user.vrentals.include?(record.vrental)
  end
end
