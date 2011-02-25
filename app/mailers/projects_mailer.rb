class ProjectsMailer < ActionMailer::Base
  default :from => "Catarse <system@catarse.me>"

  def start_project_email(about, rewards, links, contact)
    @about = about.gsub("\n", "<br>")
    @rewards = rewards.gsub("\n", "<br>")
    @links = links.gsub("\n", "<br>")
    @contact = contact
    mail(:to => "contato@catarse.me", :subject => "Projeto enviado pelo Catarse")
  end
end

