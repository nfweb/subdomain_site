require 'rails/railtie'

module SubdomainSite
  class Railtie < ::Rails::Railtie
    config.subdomain_site = {}
    config.default_subdomain = ''
    config.default_site = -> { SubdomainSite::DefaultSite.new }
    config.site_model = nil

    # Execute after all application initializers, I18n is often configured there.
    config.after_initialize do |app|
      SubdomainSite.default_site = app.config.default_site || nil
      SubdomainSite.site_model   = app.config.site_model || nil
      SubdomainSite.default_subdomain = app.config.default_subdomain || nil
    end

    initializer 'subdomain_site.core' do
      require 'subdomain_site/core'
    end

    initializer 'subdomain_site.url_helpers' do
      require 'subdomain_site/url_for'
      Rails.application.routes.extend SubdomainSite::UrlFor
    end

    initializer 'subdomain_site.route_constraint' do
      require 'subdomain_site/constraint'
    end

    initializer 'subdomain_site.controller' do
      ActiveSupport.on_load :action_controller do
        require 'subdomain_site/controller'
        include SubdomainSite::Controller
      end
    end

    initializer 'subdomain_site.acts_as_site' do
      ActiveSupport.on_load :active_record do
        require 'subdomain_site/base'
        require 'subdomain_site/acts_as_site'
        require 'subdomain_site/acts_as_site_member'
        include SubdomainSite::Base
        include SubdomainSite::ActsAsSite
        include SubdomainSite::ActsAsSiteMember
      end
      ActiveSupport.on_load :active_model do
        require 'subdomain_site/base'
        require 'subdomain_site/acts_as_site'
        require 'subdomain_site/acts_as_site_member'
        include SubdomainSite::Base
        include SubdomainSite::ActsAsSite
        include SubdomainSite::ActsAsSiteMember
      end
    end
  end
end
