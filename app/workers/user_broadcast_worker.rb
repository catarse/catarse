class UserBroadcastWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(action_data = {})
    user = User.find action_data['follow_id']

    ab = UserActionBroadcast.new(user)
    ab.broadcast_action(action_data)
  end
end
