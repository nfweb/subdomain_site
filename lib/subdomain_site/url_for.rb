module SubdomainSite
  module UrlFor
    def url_for(options, route_name = nil, url_strategy = nil)
      options = options.dup

      url_strategy ||= ActionDispatch::Routing::RouteSet::UNKNOWN if SubdomainSite::RAILS42

      if options.key?(:site)
        site = options.delete(:site)

        options[:subdomain] = site.to_param

        # force full URL if site differs from current
        if SubdomainSite::RAILS42
          url_strategy = ActionDispatch::Routing::RouteSet::FULL unless current_site?(site)
        else
          options[:only_path] = false unless current_site?(site)
        end
      end

      if SubdomainSite::RAILS42
        super
      else
        super(options)
      end
    end

    def current_site
      SubdomainSite.site
    end

    def current_site?(site)
      current_site == site
    end
  end
end

class ActionDispatch::Routing::RouteSet::NamedRouteCollection
  class UrlHelper
    if SubdomainSite::RAILS42
      def handle_positional_args_with_site(controller_options, inner_options, args, result, path_params)
        result.merge! prepare_site_options(args)
        handle_positional_args_without_site(controller_options, inner_options, args, result, path_params)
      end
    else
      def handle_positional_args_with_site(t, args, options, keys)
        options = options.dup
        options.merge prepare_site_options(args)
        handle_positional_args_without_site(t, args, options, keys)
      end
    end

    def prepare_site_options(args)
      return {} unless args.first.respond_to?(:site_member?) && args.first.site_member?

      site = args.first.site

      # remove element from args list if it is a site itself
      args.shift if args.first.respond_to?(:site?) && args.first.site?

      site_options = site.default_url_options if site.respond_to? :default_url_options
      site_options ||= {}

      site_options[:site] = site
      site_options
    end

    private :prepare_site_options

    alias_method_chain :handle_positional_args, :site

    def self.optimize_helper?(_route)
      # TODO: find implementation for optimized helper. maybe decorate ```t``?
      false
    end
  end
end
