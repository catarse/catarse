class ProjectPolicy < ApplicationPolicy

  self::UserScope = Struct.new(:current_user, :user, :scope) do
    def resolve
      if current_user.try(:admin?) || current_user == user
        scope.without_state('deleted')
      else
        scope.without_state(['deleted', 'draft', 'in_analysis', 'rejected'])
      end
    end
  end

  def create?
    done_by_owner_or_admin?
  end

  def update?
    create?
  end

  def update_account?
    record.account.invalid? || 
      ['online', 'waiting_funds', 'successful', 'failed'].exclude?(record.state) || is_admin?
  end

  def send_to_analysis?
    create?
  end

  def publish?
    create? && record.approved?
  end

  def permitted_attributes
    if user.present? && (user.admin? || (record.draft? || record.rejected? || record.in_analysis?))
      p_attr = record.attribute_names.map(&:to_sym)
      p_attr << user_attributes
      p_attr << budget_attributes
      p_attr << posts_attributes
      p_attr << reward_attributes
      p_attr << account_attributes

      p_attr.flatten
    else
      [:about_html, :video_url, :uploaded_image, :headline, :budget,
                 user_attributes, posts_attributes, budget_attributes, reward_attributes, account_attributes]
    end
  end

  def budget_attributes
    { budgets_attributes: [:id, :name, :value, :_destroy] }
  end

  def user_attributes
    { user_attributes:  [ User.attr_accessible[:default].to_a.map(&:to_sym), :id,
                          bank_account_attributes: [
                            :id, :bank_id, :agency, :agency_digit, :account,
                            :account_digit, :owner_name, :owner_document
                          ],
                          links_attributes: [:id, :_destroy, :link]
                        ] }
  end

  def posts_attributes
    { posts_attributes: [:_destroy, :title, :comment_html, :exclusive, :id]}
  end

  def reward_attributes
    { rewards_attributes: [:_destroy, :id, :maximum_contributions,
                          :description, :deliver_at, :minimum_value] }
  end

  def account_attributes
    if done_by_owner_or_admin?
      { account_attributes: ProjectAccount.attribute_names.map(&:to_sym) }
    end
  end

end

