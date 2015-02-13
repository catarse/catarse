module Project::ErrorGroups
  extend ActiveSupport::Concern

  included do
    ATTR_GROUPS = {
      basics: [:name, :permalink, :category_id, :goal, :online_days],
      project: [ :video_url, :about, :budget, :uploaded_image, :headline],
      reward: [:'rewards.size'],
      user_about: [:'user.uploaded_image', :'user.name', :'user.bio'],
      user_settings: [ :'account.full_name', :'account.email', :'account.cpf', :'account.address_street', :'account.address_number',
                       :'account.address_city', :'account.address_state', :'account.address_zip_code', :'account.phone_number',
                       :'account.bank', :'account.agency', :'account.agency_digit',
                       :'account.account' ,:'account.account_digit', :'account.owner_name',
                       :'account.owner_document']
    }

    def error_included_on_group? error_attr, group_name
      Project::ATTR_GROUPS[group_name.to_sym].include?(error_attr)
    end

    def has_errors_for?(field)
      errors.include?(field)
    end
  end
end
