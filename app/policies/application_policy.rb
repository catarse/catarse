class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.admin? || false
  end

  def new?
    create?
  end

  def update?
    user.admin? || false
  end

  def edit?
    update?
  end

  def destroy?
    user.admin? || false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def permitted?(field)
    permitted_attributes.values.first.include? field
  end

  protected
  def done_by_onwer_or_admin?
    is_owned_by?(user) || user.try(:admin?)
  end

  def is_owned_by?(user)
    user.present? && record.user == user
  end
end

