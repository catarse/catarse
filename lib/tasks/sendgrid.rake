namespace :sendgrid do
  desc 'remove mail marketing users that is on unsubscribe group'
  task sync_unsubscribe_groups: :environment do
    sendgrid = SendGrid::API.new(api_key: CatarseSettings[:sendgrid_mkt_api_key])
    MailMarketingList.where("unsubscribe_group_id is not null").find_each do |mml|
      Rails.logger.info "looking for suppressions on #{mml.label}"
      response = sendgrid.client.asm.groups._(mml.unsubscribe_group_id).suppressions.get()
      Rails.logger.info "result response #{response.status_code}"
      if response.status_code == '200'
        suppressions = ActiveSupport::JSON.decode(response.body)
        suppressions.each do |email|
          user = User.find_by email: email
          if user
            collection = mml.mail_marketing_users.where(user_id: user.id)
            Rails.logger.info "supression found for user #{user.id} on list #{mml.label} collection #{collection.inspect}"
            collection.destroy_all
          end
        end
      end
    end
  end
end
