class SubdomainSite::Constraint
  def matches? request
    request.subdomain.present? and SubdomainSite.site_model.find_by_subdomain(request.subdomain).present?
  end
end