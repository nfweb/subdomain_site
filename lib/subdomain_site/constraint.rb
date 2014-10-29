module SubdomainSite
  class Constraint
    def initialize(params = {})
      @params = params
    end

    def matches?(request)
      request.subdomain.present? && find(request.subdomain)
    end

    private

    def find(subdomain)
      SubdomainSite.site_model.find_by_subdomain(subdomain, @params)
    end
  end
end
