module Project::ErrorGroups
  extend ActiveSupport::Concern

  included do
    ATTR_GROUPS = {
      basics: [:name, :permalink, :category_id, :goal, :online_days],
      project: [ :video_url, :about, :budget, :uploaded_image, :headline],
      reward: [:'rewards.size'],
      user_about: [:'user.uploaded_image', :'user.name', :'user.bio'],
      user_settings: [ :'user.full_name', :'user.email', :'user.cpf', :'user.address_street', :'user.address_number',
                       :'user.address_city', :'user.address_state', :'user.address_zip_code', :'user.phone_number',
                       :'user.bank_account.bank', :'user.bank_account.agency', :'user.bank_account.agency_digit',
                       :'user.bank_account.account' ,:'user.bank_account.account_digit', :'user.bank_account.owner_name',
                       :'user.bank_account.owner_document']
    }

    def error_included_on_group? error_attr, group_name
      Project::ATTR_GROUPS[group_name.to_sym].include?(error_attr)
    end

    def has_errors_for?(field)
      errors.include?(field)
    end
  end
end
