# encoding: utf-8

require 'rails_helper'

RSpec.describe Blog do
  describe ".fetch_last_posts" do
    it "should fetch last posts from the blog url in configuration" do
      CatarseSettings[:blog_url] = 'test'
      Blog.fetch_last_posts
    end
  end
end
