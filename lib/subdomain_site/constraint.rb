module SubdomainSite
  class Constraint
    def initialize(params = {})
      params[:type] = params[:type].name if params.key?(:type) && params[:type].is_a?(Class)
      @params = params
    end

    def matches?(request)
      request.subdomain.present? && find(request.subdomain)
    end

    private

    def find(subdomain)
      SubdomainSite.site_model.find_subdomain_site(subdomain, @params)
    end
  end
end
