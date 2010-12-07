require 'spec_helper'

describe Project do
  it "should be valid from factory" do
    p = Factory(:project)
    p.should be_valid
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
  it "should have a goal" do
    p = Factory.build(:project, :goal => nil)
    p.should_not be_valid
  end
  it "should have a deadline" do
    p = Factory.build(:project, :deadline => nil)
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
  it "should be successful if pledged >= goal" do
    p = Factory.build(:project)
    p.goal = 3000.00
    p.pledged = 2999.99
    p.successful?.should be_false
    p.pledged = 3000.01
    p.successful?.should be_true
    p.pledged = 3000.00
    p.successful?.should be_true
  end
  it "should be expired if deadline is passed" do
    p = Factory.build(:project)
    p.deadline = 2.seconds.from_now
    p.expired?.should be_false
    p.deadline = 2.seconds.ago
    p.expired?.should be_true
  end
  it "should be in time if deadline is not passed" do
    p = Factory.build(:project)
    p.deadline = 2.seconds.ago
    p.in_time?.should be_false
    p.deadline = 2.seconds.from_now
    p.in_time?.should be_true
  end
end

