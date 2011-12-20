#encoding: utf-8
require 'spec_helper'

describe StaticController do
  render_views

  it "guidelines" do
    get :guidelines, {:locale => :pt}
    response.body.should =~ /#{I18n.t('static.guidelines.title')}/
    response.body.should =~ /#{I18n.t('static.guidelines.subtitle')}/
  end

  it "faq" do
    get :faq, {:locale => :pt}
    response.body.should =~ /#{I18n.t('static.faq.title')}/
  end

  it "terms" do
    get :terms, {:locale => :pt}
    response.body.should =~ /#{I18n.t('static.terms.title')}/
  end
end