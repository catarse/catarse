class SanitizeScriptTag
  def self.sanitize(string)
    scrubber = Rails::Html::TargetScrubber.new
    scrubber.tags = ['script']
    Loofah.fragment(string).scrub!(scrubber).to_s
  end
end
