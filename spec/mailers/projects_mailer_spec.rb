require "spec_helper"

describe ProjectsMailer do
  it "should send project" do
    about = "About the project"
    rewards = "Rewards of the project"
    links = "Links of the project"
    contact = "foo@bar.com"
    email = ProjectsMailer.start_project_email(about, rewards, links, contact).deliver
    ActionMailer::Base.deliveries.should_not be_empty
    email.encoded.should =~ /About the project/
    email.encoded.should =~ /Rewards of the project/
    email.encoded.should =~ /Links of the project/
    email.encoded.should =~ /foo@bar.com/
  end
end
