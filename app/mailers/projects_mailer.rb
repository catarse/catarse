class ProjectsMailer < ActionMailer::Base
  include ERB::Util

  def start_project_email(how_much_you_need, category, about, rewards, video, facebook,twitter, blog, links, know_us_via, contact, user, user_url)
    @how_much_you_need = h(how_much_you_need)
    @category = h(category)
    @about = h(about).gsub("\n", "<br>").html_safe
    @rewards = h(rewards).gsub("\n", "<br>").html_safe
    @video = h(video)
    @facebook = h(facebook)
    @twitter = h(twitter)
    @blog = h(blog)
    @links = h(links).gsub("\n", "<br>").html_safe
    @know_us_via = h(know_us_via).gsub("\n", "<br>").html_safe
    @contact = contact
    @user = user
    @user_url = user_url
    mail(:from => "#{I18n.t('site.name')} <#{I18n.t('site.email.system')}>", :to => I18n.t('site.email.projects'), :subject => I18n.t('projects_mailer.start_project_email.subject', :name => @user.name))
  end
end
