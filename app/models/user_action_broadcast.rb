class UserActionBroadcast
  def initialize user
    @user = user
  end

  def broadcast_action action = {}
    @user.followers.each do |uf|
      uf.notifications.find_or_create_by(
        template_name: action['template_name'],
        user: uf.user,
        locale: I18n.locale,
        from_email: UserNotifier.from_email,
        from_name: UserNotifier.from_name,
        source: uf,
        metadata: {
          follow_id: @user.id,
          project_id: action['project_id']
        }.to_json)
    end
  end
end
