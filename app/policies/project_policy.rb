class ProjectPolicy < ApplicationPolicy
  def create?
    done_by_onwer_or_admin?
  end

  def update?
    create?
  end

  def send_to_analysis?
    create?
  end

  def permitted_attributes
    if user.present? && (user.admin? || (record.draft? || record.rejected? || record.in_analysis?))
      {project: record.attribute_names.map(&:to_sym)}
    else
      {project: [:about, :video_url, :uploaded_image, :headline]}
    end
  end
end

