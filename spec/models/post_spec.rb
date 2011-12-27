# coding: utf-8
require 'spec_helper'

describe Post do

  context "#all" do
    subject{ Factory(:project).posts }
    before{ mock_tumblr }
    its(:count){ should be 2 }
    it{ subject.first["type"].should == "regular" }
    it{ subject.first["regular_title"].should == "Belo Monte de Vozes" }
  end

end