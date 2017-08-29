class MailMarketingUsersController < ApplicationController
  def subscribe
    email = params['EMAIL']
    mail_list = MailMarketingList.find_by(
      list_id: (params[:list_id] || CatarseSettings[:sendgrid_newsletter_list_id])
    )

    if email =~ EMAIL_REGEX
      user = User.find_by email: email
      if user.present?
        user.mail_marketing_users.create(
          mail_marketing_list_id: mail_list.id)
        SendgridSyncWorker.perform_async(user.id)
      else
        push_to_sendgrid(email, mail_list)
      end
    end

    redirect_to (params[:redirect_url] || :back)
  end

  def unsubscribe
    mmu = MailMarketingUser.find_by!(
      unsubcribe_token: params[:unsubcribe_token])
    mmu.destroy
    redirect_to root_path
  end

  private

  def sendgrid_api
    @sendgrid ||= SendGrid::API.new(
      api_key: CatarseSettings[:sendgrid_mkt_api_key])
  end

  def push_to_sendgrid email, mail_list
    client = sendgrid_api.client
    rr = client.contactdb.recipients.post(request_body: [{ email: email }])
    recipient = JSON.parse(rr.body).try(:[], 'persisted_recipients').try(:first)
    client.contactdb.lists._(mail_list.list_id).recipients.post(request_body: [recipient])
  end
end
