module OldBrowserChecker
  extend ActiveSupport::Concern

  def modern_browser?(browser)
    [
      browser.chrome?(">= 65"), # 03/2018
      browser.safari?(">= 10"), # 09/2016
      browser.firefox?(">= 52"), # 03/2017
      browser.ie?(">= 11") && !browser.compatibility_view?, #10/2013
      browser.edge?(">= 15"),
      browser.opera?(">= 50"), # 01/2018
      browser.facebook? && browser.safari_webapp_mode? && browser.webkit_full_version.to_i >= 602 # 09/2016
    ].any?
  end

  def detect_old_browsers
    return if modern_browser?(browser)

    redirect_to page_path('bad_browser')
  end
end
