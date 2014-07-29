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

  def permitted_attributes
    if user.present? && (user.admin? || (record.draft? || record.rejected? || record.in_analysis?))
      p_attr = [channel_ids: []]
      p_attr << record.attribute_names.map(&:to_sym)

      {project: p_attr.flatten}
    else
      {project: [:about, :video_url, :uploaded_image, :headline]}
    end
  end
end

