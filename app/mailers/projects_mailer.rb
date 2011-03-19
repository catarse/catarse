class ProjectsMailer < ActionMailer::Base
  include ERB::Util
  default :from => "Catarse <system@catarse.me>"

  def start_project_email(about, rewards, links, contact, user)
    @about = h(about).gsub("\n", "<br>").html_safe
    @rewards = h(rewards).gsub("\n", "<br>").html_safe
    @links = h(links).gsub("\n", "<br>").html_safe
    @contact = contact
    @user = user
    mail(:to => "contato@catarse.me", :subject => "Projeto enviado por #{@user.name}")
  end
end

