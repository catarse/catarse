require "spec_helper"

describe ProjectsMailer do
  it "should send project, with HTML-safe fields and converting new lines to <br>" do
    about = "About the project\n<javascript>"
    rewards = "Rewards of the project\n<javascript>"
    links = "Links of the project\n<javascript>"
    contact = "foo@bar.com"
    user = Factory(:user)
    site = Factory(:site)
    email = ProjectsMailer.start_project_email(about, rewards, links, contact, user, site).deliver
    ActionMailer::Base.deliveries.should_not be_empty
    email.encoded.should =~ /About the project\<br\>&lt;javascript&gt;/
    email.encoded.should =~ /Rewards of the project\<br\>&lt;javascript&gt;/
    email.encoded.should =~ /Links of the project\<br\>&lt;javascript&gt;/
    email.encoded.should =~ /foo@bar.com/
  end
end
