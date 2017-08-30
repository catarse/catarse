# frozen_string_literal: true

class SendgridSyncWorker
  attr_accessor :user
  include Sidekiq::Worker
  sidekiq_options queue: 'actions'

  def perform(user_id, removed_from_list_id = nil)
    @user = User.find user_id

    if removed_from_list_id.present?
      list = MailMarketingList.find removed_from_list_id
      remove_from_list(list.list_id)
      if list.list_id == CatarseSettings[:sendgrid_newsletter_list_id]
        @user.update_column(:newsletter, false)
      end
    else
      unsync_list = @user.mail_marketing_users.unsynced
      return if unsync_list.empty?

      has_sendgrid_recipient = user.sendgrid_recipient_id.present?

      update_user_recipient_id(
        (has_sendgrid_recipient ? update_recipient : find_or_create_recipient)
      )

     unsync_list.find_each do |mu|
        put_on_list mu.mail_marketing_list.list_id
        mu.update_column(:last_sync_at, DateTime.now)
      end
    end
  end

  private

  def put_on_list list_id
    recipient_id = user.sendgrid_recipient_id
    sendgrid_lists._(list_id).recipients._(recipient_id).post
  end

  def remove_from_list list_id
    recipient_id = user.sendgrid_recipient_id
    sendgrid_lists._(list_id).recipients._(recipient_id).delete
  end

  def find_or_create_recipient
    search_recipient.present? ? search_recipient : create_recipient
  end

  def update_recipient
    params = { request_body: [prepare_user_to_sendgrid] }
    parse_from_response sendgrid_recipients.patch(params)
  end

  def create_recipient
    params = { request_body: [prepare_user_to_sendgrid] }
    parse_from_response sendgrid_recipients.post(params)
  end

  def search_recipient
    params = { email: user.email }
    parse_from_response(
      sendgrid_recipients.search.get(query_params: params),
      'recipients'
    ).try(:[], 'id')
  end

  def parse_from_response(response, opt_path = 'persisted_recipients')
    JSON.parse(response.body).try(:[], opt_path).try(:first)
  end

  def update_user_recipient_id(recipient)
    user.update_column(:sendgrid_recipient_id, recipient)
  end

  def prepare_user_to_sendgrid
    name_mask = begin
                  user.name.split(' ')
                rescue
                  ['', '']
                end
    {
      email: user.email,
      last_name: name_mask.pop,
      first_name: name_mask.join(' '),
      'Cidade': user.address_city,
      'Estado': user.address_state
    }
  end

  def sendgrid
    @sendgrid ||= SendGrid::API.new(api_key: CatarseSettings[:sendgrid_mkt_api_key])
  end

  def sendgrid_lists
    sendgrid.client.contactdb.lists
  end

  def sendgrid_recipients
    sendgrid.client.contactdb.recipients
  end
end
