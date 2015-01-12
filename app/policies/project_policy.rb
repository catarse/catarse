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

  def send_to_analysis?
    create?
  end

  def publish?
    create? && record.approved?
  end

  def permitted_attributes
    if user.present? && (user.admin? || (record.draft? || record.rejected? || record.in_analysis?))
      p_attr = [channel_ids: []]
      p_attr << record.attribute_names.map(&:to_sym)
      p_attr << user_attributes

      {project: p_attr.flatten}
    else
      {project: [:about, :video_url, :uploaded_image, :headline, user_attributes]}
    end
  end

  def user_attributes
    { user_attributes: [User.attr_accessible[:default].to_a.map(&:to_sym), :id] }
  end
end

