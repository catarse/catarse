require 'spec_helper'

describe Project do
  it "should be valid from factory" do
    p = Factory(:project)
    p.should be_valid
  end
  it "should validate presence of name" do
    p = Factory.build(:project, :name => nil)
    p.should_not be_valid
  end
  it "should validate presence of user" do
    p = Factory.build(:project, :user => nil)
    p.should_not be_valid
  end
  it "should validate presence of category" do
    p = Factory.build(:project, :category => nil)
    p.should_not be_valid
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
  it "should say the time left, acording to deadline" do
    p = Factory.build(:project)
    # TODO use translation here??
    p.deadline = 10.days.from_now
    p.time_left.should equal("10 dias")
    p.deadline = 37.hours.from_now
    p.time_left.should equal("2 dias")
    p.deadline = 36.hours.from_now
    p.time_left.should equal("1 dia")
    p.deadline = 25.hours.from_now
    p.time_left.should equal("1 dia")
    p.deadline = 24.hours.from_now
    p.time_left.should equal("1 dia")
    p.deadline = 23.hours.from_now
    p.time_left.should equal("23 horas")
    p.deadline = 2.hours.from_now
    p.time_left.should equal("2 horas")
    p.deadline = 91.minutes.from_now
    p.time_left.should equal("2 horas")
    p.deadline = 90.minutes.from_now
    p.time_left.should equal("1 hora")
    p.deadline = 89.minutes.from_now
    p.time_left.should equal("1 hora")
    p.deadline = 60.minutes.from_now
    p.time_left.should equal("1 hora")
    p.deadline = 59.minutes.from_now
    p.time_left.should equal("59 minutos")
    p.deadline = 1.minute.from_now
    p.time_left.should equal("1 minuto")
    p.deadline = 59.seconds.from_now
    p.time_left.should equal("59 segundos")
    p.deadline = 1.second.from_now
    p.time_left.should equal("1 segundo")
    p.deadline = 0.seconds.from_now
    p.time_left.should equal("0 segundos")
    p.deadline = 1.second.ago
    p.time_left.should equal("0 segundos")
    p.deadline = 1.hour.ago
    p.time_left.should equal("0 segundos")
    p.deadline = 10.days.ago
    p.time_left.should equal("0 segundos")
  end
end

