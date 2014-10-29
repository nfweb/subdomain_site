ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'minitest/autorun'
require 'rails/test_help'
Rails.backtrace_cleaner.remove_silencers!

$VERBOSE = true

module SubdomainSite
  module Test
    module UrlFor
      require 'action_dispatch/routing/route_set'
      def url_for(*args)
        params = args.first
        if SubdomainSite::RAILS42
          params[:only_path] = false if args.third == ActionDispatch::Routing::RouteSet::FULL
          params[:only_path] = false if args.third == ActionDispatch::Routing::RouteSet::UNKNOWN
          puts args.third.inspect unless params.key? :only_path
        end
        params
      end
    end
  end
end
