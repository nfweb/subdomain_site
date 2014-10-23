module SubdomainSite
  module Controller
    def self.included(base)
      base.around_filter :set_site
    end

    def current_site
      SubdomainSite.site
    end

    private

    def set_site
      site = SubdomainSite.site_for(request.subdomain)
      site = SubdomainSite.default_fallback(site)
      SubdomainSite.with_site(site) { yield }
    end
  end
end
