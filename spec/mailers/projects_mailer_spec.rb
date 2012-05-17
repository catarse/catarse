require "spec_helper"

describe ProjectsMailer do
  it "should send project, with HTML-safe fields and converting new lines to <br>" do
    how_much_you_need = "1000 <javascript>"
    category = "art <javascript>"
    about = "About the project\n<javascript>"
    rewards = "Rewards of the project\n<javascript>"
    video = "http://vimeo.com/9090 <javascript>"
    twitter = "username <javascript>"
    facebook = "FB username <javascript>"
    blog = "www.lorem.com <javascript>"
    links = "Links of the project\n<javascript>"
    know_us_via = "My friends\n<javascript>"
    contact = "foo@bar.com"
    user = Factory(:user)
    email = ProjectsMailer.start_project_email(how_much_you_need, category, about, rewards, video, facebook, twitter, blog, links, know_us_via, contact, user, "#{I18n.t('site.base_url')}#{user_path(user)}").deliver
    ActionMailer::Base.deliveries.should_not be_empty
    email.encoded.should =~ /1000 &lt;javascript&gt;/
    email.encoded.should =~ /About the project\<br\>&lt;javascript&gt;/
    email.encoded.should =~ /Rewards of the project\<br\>&lt;javascript&gt;/
    email.encoded.should =~ /Links of the project\<br\>&lt;javascript&gt;/
    email.encoded.should =~ /foo@bar.com/
    email[:from].to_s.should == "#{I18n.t('site.name')} <#{I18n.t('site.email.system')}>"
  end
end
