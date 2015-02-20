module Project::ErrorGroups
  extend ActiveSupport::Concern

  included do
    ATTR_GROUPS = {
      basics: [:name, :permalink, :category_id, :goal, :online_days],
      project: [ :video_url, :about, :budget, :uploaded_image, :headline],
      reward: [:'rewards.size'],
      user_about: [:'user.uploaded_image', :'user.name', :'user.bio'],
      user_settings: [ :'project_account.full_name', :'project_account.email', :'project_account.cpf', :'project_account.address_street', :'project_account.address_number',
                       :'project_account.address_city', :'project_account.address_state', :'project_account.address_zip_code', :'project_account.phone_number',
                       :'project_account.bank', :'project_account.agency', :'project_account.agency_digit',
                       :'project_account.project_account' ,:'project_account.project_account_digit', :'project_account.owner_name',
                       :'project_account.owner_document']
    }

    def error_included_on_group? error_attr, group_name
      Project::ATTR_GROUPS[group_name.to_sym].include?(error_attr)
    end

    def has_errors_for?(field)
      errors.include?(field)
    end
  end
end
