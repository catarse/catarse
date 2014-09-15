require 'spec_helper'

describe PostPreviewController do
  subject{ response }

  describe "GET show" do
    before do
      get :show, text: 'h1. should convert me! :D', locale: :pt
    end

    it{ should be_success }

    it "should convert text to html" do
      expect(subject.body).to eq('<h1>should convert me! :D</h1>')
    end
  end
end
