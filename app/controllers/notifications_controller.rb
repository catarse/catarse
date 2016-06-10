class NotificationsController < ApplicationController
  def show
    raise Pundit::NotAuthorizedError if !current_user
    @notification = kclass.find(params[:notification_id])
    raise Pundit::NotAuthorizedError unless current_user.admin || current_user == @notification.user

    render "user_notifier/mailer/#{@notification.template_name}", locals: { notification:  @notification }, layout: 'layouts/email'
  end

  private
  def kclass
    @kclass ||= params[:notification_type].camelize.constantize
  end
end
