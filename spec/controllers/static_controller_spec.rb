#encoding: utf-8
require 'spec_helper'

describe StaticController do

  render_views
  subject{ response }

  describe 'GET guidelines' do
    before{ get :guidelines, {:locale => :pt} }
    it{ should be_success }
    its(:body){ should =~ /#{I18n.t('static.guidelines.title')}/ }
    its(:body){ should =~ /#{I18n.t('static.guidelines.subtitle')}/ }
  end

  describe 'GET faq' do
    before{ get :faq, {:locale => :pt} }
    it{ should be_success }
    its(:body){ should =~ /#{I18n.t('static.faq.title')}/ }
  end

  describe "GET terms" do
    before{ get :terms, {:locale => :pt} }
    it{ should be_success }
    its(:body){ should =~ /#{I18n.t('static.terms.title')}/ }
  end

  describe "GET sitemap" do
    before{ get :sitemap, {:locale => :pt} }
    it{ should be_success }
  end
end