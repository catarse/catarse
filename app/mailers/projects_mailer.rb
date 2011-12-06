class ProjectsMailer < ActionMailer::Base
  include ERB::Util
  default :from => "#{t('site.name')} <#{t('site.email.system')}>"

  def start_project_email(about, rewards, links, contact, user, user_url)
    @about = h(about).gsub("\n", "<br>").html_safe
    @rewards = h(rewards).gsub("\n", "<br>").html_safe
    @links = h(links).gsub("\n", "<br>").html_safe
    @contact = contact
    @user = user
    @user_url = user_url
    mail(:to => t('site.email.projects'), :subject => t('projects_mailer.start_project_email.subject', :name => @user.name))
  end
end
