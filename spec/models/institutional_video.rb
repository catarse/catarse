require 'spec_helper'

describe InstitutionalVideo do
  context "validations" do
    %w(title description video_url).each do |field|
      it{ should validate_presence_of field.to_sym }
    end
  end
  
  describe "scopes" do
    context "visibles" do
      before(:each) do
        10.times { Factory.create(:institutional_video, :visible => true )}
        4.times { Factory.create(:institutional_video, :visible => false )}        
      end
      
      it "should show only visibles" do
        InstitutionalVideo.all.should have(14).iten
        InstitutionalVideo.visibles.should have(10).itens
      end
    end
  end
end
