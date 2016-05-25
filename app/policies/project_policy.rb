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

  def push_to_online?
    done_by_owner_or_admin?
  end

  def update?
    create?
  end

  def push_to_flex?
    is_admin?
  end

  def update_account?
    record.account.new_record? || !record.published? || is_admin?
  end

  def send_to_analysis?
    create?
  end

  def publish?
    done_by_owner_or_admin?
  end

  def validate_publish?
    done_by_owner_or_admin?
  end

  def permitted_attributes
    if user.present? && (user.admin? || (record.draft? || record.rejected? || record.in_analysis? || record.approved?))
      p_attr = record.attribute_names.map(&:to_sym)
      p_attr << :all_tags
      p_attr << user_attributes
      p_attr << budget_attributes
      p_attr << posts_attributes
      p_attr << reward_attributes
      p_attr << account_attributes

      p_attr.flatten

      # TODO: This code is to prevent not allowed
      # fields without admin for legacy dashboard
      unless user.admin?
        not_allowed = [
          :audited_user_name, :audited_user_cpf, :audited_user_phone_number,
          :state, :origin_id, :service_fee, :total_installments,
          :recommended, :created_at, :updated_at
        ]
        p_attr.delete_if { |key| not_allowed.include?(key) }
      end

      p_attr
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
      { account_attributes: ProjectAccount.attribute_names.map(&:to_sym) << :input_bank_number }
    end
  end

end

