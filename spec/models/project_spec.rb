require 'spec_helper'

describe Project do
  it "should be valid from factory" do
    p = Factory(:project)
    p.should be_valid
  end
  it "display_image should return image_url if it exists" do
    p = Factory(:project, :image_url => 'http://test.com/image')
    p.display_image.should == 'http://test.com/image'
  end
  it "should get vimeo image URL and store it" do
    p = Factory.build(:project)
    p.stubs(:vimeo).returns({'id' => '1', 'thumbnail_large' => 'http://b.vimeocdn.com/ts/117/614/117614276_200.jpg'})
    p.stubs(:vimeo_id).returns('1')
    p.save!
    p.reload
    p.image_url.should == 'http://b.vimeocdn.com/ts/117/614/117614276_200.jpg'
  end
  it "should have a name" do
    p = Factory.build(:project, :name => nil)
    p.should_not be_valid
  end
  it "should have an user" do
    p = Factory.build(:project, :user => nil)
    p.should_not be_valid
  end
  it "should have a category" do
    p = Factory.build(:project, :category => nil)
    p.should_not be_valid
  end
  it "should have a video URL" do
    p = Factory.build(:project, :video_url => nil)
    p.should_not be_valid
  end
  it "should have an about text" do
    p = Factory.build(:project, :about => nil)
    p.should_not be_valid
  end
  it "should have a headline" do
    p = Factory.build(:project, :headline => nil)
    p.should_not be_valid
  end
  it "should not be valid with a headline longer than 140 characters" do
    p = Factory.build(:project)
    p.headline = "a".center(139)
    p.should be_valid
    p.headline = "a".center(140)
    p.should be_valid
    p.headline = "a".center(141)
    p.should_not be_valid
  end
  it "should have a goal" do
    p = Factory.build(:project, :goal => nil)
    p.should_not be_valid
  end
  it "should have an expires_at date" do
    p = Factory.build(:project, :expires_at => nil)
    p.should_not be_valid
  end
  it "should have a valid Vimeo video URL" do
    p = Factory.build(:project, :video_url => "http://youtube.com/foobar")
    p.should_not be_valid
    p = Factory.build(:project, :video_url => "http://www.vimeo.com/172984359999999")
    p.should_not be_valid
    p = Factory.build(:project, :video_url => "http://vimeo.com/172984359999999")
    p.should_not be_valid
    p = Factory.build(:project, :video_url => "http://www.vimeo.com/17298435")
    p.should be_valid
    p = Factory.build(:project, :video_url => "http://vimeo.com/17298435")
    p.should be_valid
  end
  it "should have a vimeo_id" do
    p = Factory(:project, :video_url => "http://vimeo.com/17298435")
    p.vimeo_id.should == "17298435"
  end
  it "should have a video_embed_url" do
    p = Factory(:project, :video_url => "http://vimeo.com/17298435")
    p.video_embed_url.should == "http://player.vimeo.com/video/17298435"
  end
  it "should have a vimeo object" do
    p = Factory(:project, :video_url => "http://vimeo.com/17298435")
    p.vimeo.should_not be_nil
  end
  it "should have a nil vimeo object if the video doesn't exist" do
    p = Factory.build(:project, :video_url => "http://vimeo.com/000000000")
    p.vimeo.should be_nil
  end
  it "should have a nil vimeo object even if we get an error from Vimeo" do
    Vimeo::Simple::Video.stubs(:info).returns(Exception.new)
    p = Factory.build(:project, :video_url => "http://vimeo.com/000000000")
    p.vimeo.should be_nil
  end
  it "should be successful if pledged >= goal" do
    p = Factory.build(:project)
    p.goal = 3000.00
    Factory(:backer, :project => p, :value => 2999.99)
    p.successful?.should be_false
    p.backers.destroy_all
    Factory(:backer, :project => p, :value => 3000.00)
    p.successful?.should be_true
    p.backers.destroy_all
    Factory(:backer, :project => p, :value => 3000.01)
    p.successful?.should be_true
  end
  it "should be expired if expires_at is passed" do
    p = Factory.build(:project)
    p.expires_at = 2.seconds.from_now
    p.expired?.should be_false
    p.expires_at = 2.seconds.ago
    p.expired?.should be_true
  end
  it "should be in time if expires_at is not passed" do
    p = Factory.build(:project)
    p.expires_at = 2.seconds.ago
    p.in_time?.should be_false
    p.expires_at = 2.seconds.from_now
    p.in_time?.should be_true
  end
  it "should have a display image" do
    p = Factory(:project)
    p.display_image.should_not be_empty
  end
  it "should have a HTML-safe about_html, with textile and regular links" do
    p = Factory.build(:project)
    p.about = 'Foo Bar http://www.foo.bar <javascript>xss()</javascript>"Click here":http://click.here'
    p.about_html.should == '<p>Foo Bar <a href="http://www.foo.bar" target="_blank">http://www.foo.bar</a> &lt;javascript&gt;xss()&lt;/javascript&gt;<a target="_blank" href="http://click.here">Click here</a></p>'
  end
  it "should be able to display the remaining time with days, hours, minutes and seconds" do
    p = Factory.build(:project)
    time = Time.now
    Time.stubs(:now).returns(time)
    p.expires_at = 30.days.from_now
    p.time_to_go[:time].should == 30
    p.time_to_go[:unit].should == "dias"
    p.expires_at = 1.day.from_now
    p.time_to_go[:time].should == 1
    p.time_to_go[:unit].should == "dia"
    p.expires_at = 23.hours.from_now + 59.minutes + 59.seconds
    p.time_to_go[:time].should == 24
    p.time_to_go[:unit].should == "horas"
    p.expires_at = 1.hour.from_now
    p.time_to_go[:time].should == 1
    p.time_to_go[:unit].should == "hora"
    p.expires_at = 59.minutes.from_now
    p.time_to_go[:time].should == 59
    p.time_to_go[:unit].should == "minutos"
    p.expires_at = 1.minute.from_now
    p.time_to_go[:time].should == 1
    p.time_to_go[:unit].should == "minuto"
    p.expires_at = 59.seconds.from_now
    p.time_to_go[:time].should == 59
    p.time_to_go[:unit].should == "segundos"
    p.expires_at = 1.second.from_now
    p.time_to_go[:time].should == 1
    p.time_to_go[:unit].should == "segundo"
    p.expires_at = 0.seconds.from_now
    p.time_to_go[:time].should == 0
    p.time_to_go[:unit].should == "segundos"
    p.expires_at = 1.second.ago
    p.time_to_go[:time].should == 0
    p.time_to_go[:unit].should == "segundos"
    p.expires_at = 30.days.ago
    p.time_to_go[:time].should == 0
    p.time_to_go[:unit].should == "segundos"
  end
  it "should be waiting confirmation until 3 weekdays after the deadline unless it is already successful" do
    p = Factory(:project, :goal => 100)
    time = Time.local 2011, 03, 04
    Time.stubs(:now).returns(time)
    p.successful?.should be_false
    p.expires_at = 1.minute.from_now
    p.waiting_confirmation?.should be_false
    p.expires_at = 4.weekdays_ago
    p.waiting_confirmation?.should be_false
    p.expires_at = 3.weekdays_ago - 1.minute
    p.waiting_confirmation?.should be_false
    p.expires_at = 3.weekdays_ago + 1.minute
    p.waiting_confirmation?.should be_true
    p.expires_at = 2.weekdays_ago
    p.waiting_confirmation?.should be_true
    Factory(:backer, :project => p, :value => 100, :confirmed => true)
    p.successful?.should be_true
    p.expires_at = 3.weekdays_ago + 1.minute
    p.waiting_confirmation?.should be_false
    p.expires_at = 2.weekdays_ago
    p.waiting_confirmation?.should be_false
  end
  
  it "should be able to be in more than one curated page" do
    cp = Factory.build(:curated_page)
    cp2 = Factory.build(:curated_page)
    p = Factory.build(:project, :curated_pages => [cp,cp2])
    p.curated_pages.size.should be 2
    p.should be_valid
  end
end


# == Schema Information
#
# Table name: projects
#
#  id          :integer         not null, primary key
#  name        :text            not null
#  user_id     :integer         not null
#  category_id :integer         not null
#  goal        :decimal(, )     not null
#  expires_at  :datetime        not null
#  about       :text            not null
#  headline    :text            not null
#  video_url   :text            not null
#  image_url   :text
#  short_url   :text
#  created_at  :datetime
#  updated_at  :datetime
#  can_finish  :boolean         default(FALSE)
#  finished    :boolean         default(FALSE)
#  about_html  :text
#  site_id     :integer         default(1), not null
#

