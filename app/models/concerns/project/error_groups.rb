module Project::ErrorGroups
  extend ActiveSupport::Concern

  included do
    begin
      ATTR_GROUPS = {
        basics: [:name, :permalink, :category_id, :goal, :online_days],
        description: [:about_html],
        budget: [:budget],
        card: [:uploaded_image, :headline],
        video: [:video_url],
        reward: [:'rewards.size', :'rewards.minimum_value', :'rewards.deliver_at'],
        user_about: [:'user.uploaded_image', :'user.name', :'user.about_html'],
        user_settings: ProjectAccount.attribute_names.map{|attr| ('project_account.' + attr).to_sym} << :account
      }
    rescue Exception => e
      puts "problem while using ErrorGroups concenr:\n '#{e.message}'"
    end

    def error_included_on_group? error_attr, group_name
      Project::ATTR_GROUPS[group_name.to_sym].include?(error_attr)
    end

    def has_errors_for?(field)
      errors.include?(field)
    end
  end
end
