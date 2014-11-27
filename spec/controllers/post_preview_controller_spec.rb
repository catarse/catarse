require 'rails_helper'

RSpec.describe PostPreviewController, type: :controller do
  subject{ response }

  describe "GET show" do
    before do
      get :show, text: '**should convert me! :D**', locale: :pt
    end

    it{ is_expected.to be_success }

    it "should convert text to html" do
      expect(subject.body).to eq("<p><strong>should convert me! :D</strong></p>\n")
    end
  end
end
