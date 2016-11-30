class SendgridSyncWorker
  attr_accessor :user
  include Sidekiq::Worker
  sidekiq_options queue: 'actions'

  def perform user_id
    @user = User.find user_id

    if user.sendgrid_recipient_id.present?
      update_recipient
    else
      find_or_create_recipient
    end

    # TODO: add support to remove and put recipient on newsletter list
    # remove_from_newsletter if recipient_on_newsletter? && !user.newsletter
    # put_on_newsletter if !recipient_on_newsletter? && user.newsletter
  end

  private

  def find_or_create_recipient
    if search_recipient.present?
      user.update_column(:sendgrid_recipient_id, search_recipient[:id])
    else
      persisted_recipient = create_recipient
      user.update_column(:sendgrid_recipient_id, persisted_recipient)
    end
  end

  def update_recipient
    params = { request_body: [prepare_user_to_sendgrid] }
    parse_recipients_from_response sendgrid_recipients.patch(params)
  end

  def create_recipient
    params = { request_body: [prepare_user_to_sendgrid] }
    parse_recipients_from_response sendgrid_recipients.post(params)
  end

  def search_recipient
    params = { email: user.email }
    response = sendgrid_recipients.search.get(query_params: params)
    JSON.parse(response.body).try(:[], 'recipients').try(:first).try(:deep_symbolize_keys)
  end

  def parse_recipients_from_response response
    JSON.parse(response.body).try(:[], 'persisted_recipients').first
  end

  def prepare_user_to_sendgrid
    name_mask = user.name.split ' '
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

  def sendgrid_recipients
    sendgrid.client.contactdb.recipients
  end
end
