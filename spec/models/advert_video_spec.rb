require 'spec_helper'

describe AdvertVideo do
  context "validations" do
    %w(title description video_url).each do |field|
      it{ should validate_presence_of field.to_sym }
    end
  end
  
  describe "scopes" do
    context "visibles" do
      before(:each) do
        10.times { Factory.create(:advert_video, :visible => true )}
        4.times { Factory.create(:advert_video, :visible => false )}        
      end
      
      it "should show only visibles" do
        AdvertVideo.all.should have(14).iten
        AdvertVideo.visibles.should have(10).itens
      end
    end
  end
end
