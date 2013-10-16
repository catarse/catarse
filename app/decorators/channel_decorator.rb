class ChannelDecorator < Draper::Decorator
  decorates :channel

  def display_facebook
    last_fragment(source.facebook)
  end

  def display_twitter
    "@#{last_fragment(source.twitter)}"
  end

  def display_website
    source.website.gsub(/https?:\/\//i, '')
  end

  private
  def last_fragment(uri)
    uri.split("/").last
  end
end
