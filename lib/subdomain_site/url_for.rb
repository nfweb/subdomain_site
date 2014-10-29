module SubdomainSite
  module UrlFor
    # Makes url_for(site: 'admin') the same as url_for(subdomain: 'admin', only_path: false)
    def url_for(options, route_name = nil, url_strategy = nil)
      options = options.dup

      if options.key?(:site)
        site = options.delete(:site)

        site_options = site.default_url_options if site.respond_to? :default_url_options
        site_options ||= { subdomain: site.to_param }

        options.reverse_merge! site_options

        # if site specified force full URL
        if SubdomainSite::RAILS42
          url_strategy = ActionDispatch::Routing::RouteSet::FULL unless current_site?(site)
        else
          options[:only_path] = current_site?(site) && options[:only_path].present? && options[:only_path]
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
        if args.first.respond_to?(:site_member?) && args.first.site_member?
          result[:site] = args.first.site
          args.shift if args.first.respond_to?(:site?) && args.first.site?
        end
        handle_positional_args_without_site(controller_options, inner_options, args, result, path_params)
      end
    else
      def handle_positional_args_with_site(t, args, options, keys)
        options = options.dup
        if args.first.respond_to?(:site_member?) && args.first.site_member?
          options[:site] = args.first.site
          args.shift if args.first.respond_to?(:site?) && args.first.site?
        end
        handle_positional_args_without_site(t, args, options, keys)
      end
    end

    alias_method_chain :handle_positional_args, :site

    def self.optimize_helper?(_route)
      # TODO: find implementation for optimized helper. maybe decorate ```t``?
      false
    end
  end

  class OptimizedUrlHelper
    def call(t, args)
      if args.size == arg_size && !args.last.is_a?(Hash) && optimize_routes_generation?(t)
        options = @options.dup
        options.merge!(t.url_options) if t.respond_to?(:url_options)
        options[:path] = optimized_helper(args)
        ActionDispatch::Http::URL.url_for(options)
      else
        super
      end
    end
  end
end
