begin
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
rescue LoadError
end

ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'minitest/autorun'
require 'rails/test_help'
Rails.backtrace_cleaner.remove_silencers!

$VERBOSE = true

module SubdomainSite
  module Test
    module UrlForParent
      if SubdomainSite::RAILS42
        def url_strategies
          @strategies ||= {
            full: ActionDispatch::Routing::RouteSet::FULL,
            path: ActionDispatch::Routing::RouteSet::PATH,
            unknown: ActionDispatch::Routing::RouteSet::UNKNOWN
          }
        end

        def url_for(options, _route_name, url_strategy)
          [options, url_strategies.invert[url_strategy]]
        end
      else
        def url_strategies
          @strategies ||= {
            full: :full,
            path: :path,
            unknown: :unknown
          }
        end

        def url_for(options)
          url_strategy = :unknown unless options.key? :only_path
          url_strategy ||= options.delete(:only_path) ? :path : :full
          [options, url_strategy]
        end
      end
    end

    module UrlForTestChild
      if SubdomainSite::RAILS42
        def url_for(options, route_name = nil, url_strategy = :unknown)
          url_strategy = url_strategies[url_strategy]
          super
        end
      else
        def url_for(options, _route_name = nil, url_strategy = :unknown)
          options = options.dup
          options[:only_path] = url_strategy == :path unless url_strategy == :unknown
          super(options)
        end
      end
    end

    module UrlForWrapper
      include UrlForParent
      include ::SubdomainSite::UrlFor
      include UrlForTestChild
    end
  end
end
