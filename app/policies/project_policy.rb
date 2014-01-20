class ProjectPolicy < ApplicationPolicy
  def create?
    is_owned_by? user
  end

  def update?
    user.present? && (user.admin? || record.user == user)
  end

  def send_to_analysis?
    update?
  end

  def permitted_attributes
    if user.present? && (user.admin? || (record.draft? || record.rejected? || record.in_analysis?))
      {project: record.attribute_names}
    else
      {project: [:about, :video_url, :uploaded_image, :headline]}
    end
  end
end

