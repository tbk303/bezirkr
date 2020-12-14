module Parsing
  extend ActiveSupport::Concern

  SANITIZER = Rails::Html::SafeListSanitizer.new
  SCRUBBER = Rails::Html::TargetScrubber.new
  SCRUBBER.tags = %w[font tabref div iframe h1 h2 a]
  SCRUBBER.attributes = %w[class target cellpadding cellspacing width height start type]

  XPATHS_TO_REMOVE = %w{.//script .//form comment()}

  def clean_html(node)
    return nil if node.nil?

    node.xpath(*XPATHS_TO_REMOVE).remove
    cleaned = SANITIZER.sanitize(node.inner_html, scrubber: SCRUBBER)
    cleaned = cleaned.gsub(/font-family:([^;]*);/, '').gsub(/font-size:([^;]*);/, '')
    cleaned
  end

  def retrieve_xpath_div(html, xpath_content)
    clean_html(html.xpath("//span[contains(text(), '#{xpath_content}')]").first&.ancestors('div')&.first)&.sub(xpath_content, '')
  end

  def strip_tags(content)
    ActionController::Base.helpers.strip_tags(content)
  end
end