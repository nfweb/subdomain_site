module SubdomainSite
  module UrlFor
    # Makes url_for(locale: 'ru') the same as url_for(subdomain: 'ru', only_path: false)
    # That way you can easily swap locale in subdomain with locale in the path.
    #
    # E. g. assuming you have <tt>scope ":locale"</tt> in your routes:
    #   url_for params.merge(locale: 'ru') # => /ru/current_path
    # After including this module:
    #   url_for params.merge(locale: 'ru') # => http://ru.example.com/current_path
    def url_for(options, route_name = nil, url_strategy = nil)
      options = options.dup

      if Gem::Version.new(Rails.version) >= Gem::Version.new('4.2.0beta1')
        url_strategy = ActionDispatch::Routing::RouteSet::UNKNOWN if url_strategy.nil?
      end

      if options.key?(:site)
        # Site specified, force full URL
        site = options.delete(:site)
        options[:subdomain] = SubdomainSite.subdomain_for(site)

        if Gem::Version.new(Rails.version) < Gem::Version.new('4.2.0beta1')
          options[:only_path] = current_site?(site) && options[:only_path].present? && options[:only_path]
        else
          url_strategy = ActionDispatch::Routing::RouteSet::FULL unless current_site?(site)
        end
      end

      if Gem::Version.new(Rails.version) >= Gem::Version.new('4.2.0beta1')
        super
      else
        super(options)
      end
    end

    # def default_url_options
    #   super.merge({
    #     subdomain: SubdomainSite.subdomain_for(current_site)
    #   })
    # end

    def current_site
      SubdomainSite.site
    end

    def current_site?(site)
      current_site.to_s == site.to_s
    end
  end
end

class ActionDispatch::Routing::RouteSet::NamedRouteCollection
  class UrlHelper
    if Gem::Version.new(Rails.version) < Gem::Version.new('4.2.0beta1')
      def handle_positional_args_with_site(t, args, options, keys)
        options = options.dup
        if args.first.respond_to?(:site_member?) && args.first.site_member?
          options[:site] = args.first.site
        end
        handle_positional_args_without_site(t, args, options, keys)
      end
    else
      def handle_positional_args_with_site(controller_options, inner_options, args, result, path_params)
        if args.first.respond_to?(:site_member?) && args.first.site_member?
          result[:site] = args.first.site
        end
        handle_positional_args_without_site(controller_options, inner_options, args, result, path_params)
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
