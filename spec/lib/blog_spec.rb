# encoding: utf-8

require 'spec_helper'

describe Blog do
  describe ".fetch_last_posts" do
    it "should fetch last posts from the blog url in configuration" do
      ::Configuration[:blog_url] = 'test'
      #Feedzirra::Feed.expects(:fetch_and_parse).with("test?feed=rss2")
      Blog.fetch_last_posts
    end
  end
end
