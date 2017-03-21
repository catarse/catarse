module Project::ErrorGroups
  extend ActiveSupport::Concern

  included do
    def attr_error_groups
      {
        basics: [:public_name, :permalink, :category_id, :city, :public_tags],
        goal: [:goal, :online_days],
        description: [:about_html],
        budget: [:budget],
        announce_expiration: [:online_days],
        card: [:uploaded_image, :headline],
        video: [:video_url],
        reward: [:'rewards.size', :'rewards.minimum_value', :'rewards.description', :'rewards.deliver_at', :'rewards.shipping_fees.value', :'rewards.shipping_fees.destination'],
        user_about: [:'user.uploaded_image', :'user.public_name', :'user.about_html'],
        user_settings: user_settings_error_group
      }
    end

    def error_included_on_group? error_attr, group_name
      attr_error_groups[group_name.to_sym].include?(error_attr)
    end

    def has_errors_for?(field)
      errors.include?(field)
    end

    def user_settings_error_group
      attr_map = BankAccount.attribute_names.map{ |attr| ('bank_account.' + attr).to_sym }
      attr_map.concat(%i(user.name user.cpf user.birth_date user.country_id user.address_state user.address_street user.address_number user.address_city user.address_neighbourhood bank_account))
      attr_map
    end

  end
end
