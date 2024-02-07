class PostPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    return true
  end

  def new?
    return create?
  end

  def create?
    user.admin? || user.manager?
  end

  def edit?
    return update?
  end

  def update?
    user.admin? || user.manager?
  end

  def destroy?
    user.admin? || user.manager?
  end

  def toggle_hidden?
    user.admin? || user.manager?
  end

  def get_news?
    user.admin? || user.manager?
  end
end
