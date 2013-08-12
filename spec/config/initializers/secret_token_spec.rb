require 'spec_helper'
require 'securerandom'

describe 'Secret Token' do

  context 'show secret token' do
    it do     
      Mobilexpert::Application.config.secret_token.should eql(File.read(Rails.root.join('.secret')))
    end
  end

  context 'with secret file created' do
    it { find_secure_token.should eql(File.read(Rails.root.join('.secret')).chomp) }
  end

  context 'without file created' do
    it do
      file = Rails.root.join('.secret')
      file.delete if File.exist? file
      find_secure_token.should eql(File.read(file).chomp)
    end
  end

end