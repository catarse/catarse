class ProjectPolicy < ApplicationPolicy
  def create?
    user.present? && record.user == user
  end

  def update?
    user.present? && (user.admin? || record.user == user)
  end

  def send_to_analysis?
    update?
  end

  def permitted_attributes(params)
    if user.present? && (user.admin? || (record.draft? || record.rejected? || record.in_analysis?))
      params.permit!
    else
      params.permit(project: [:about, :video_url, :uploaded_image, :headline])
    end
  end
end

