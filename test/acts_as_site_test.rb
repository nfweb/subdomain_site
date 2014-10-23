require_relative 'test_helper'
require 'subdomain_site/acts_as_site'

class ActsAsSiteTest < ActiveSupport::TestCase
  class SimpleSite
    include ActiveModel::Model
    include SubdomainSite::ActsAsSite
    attr_accessor :subdomain
    acts_as_site

    def initialize(subdomain)
      self.subdomain = subdomain
    end
  end

  class Site
    include ActiveModel::Model
    include SubdomainSite::ActsAsSite
    attr_accessor :slug
    acts_as_site :slug

    def initialize(subdomain = nil)
      self.slug = subdomain
    end
  end

  def default_testing(site)
    assert site.site_member?
    assert site.site?
    assert_equal site.site, site
    assert_respond_to site, :subdomain
    assert_respond_to site, :subdomain=
  end

  def test_simple_site
    site = SimpleSite.new(:peter)
    default_testing(site)
    site.subdomain = 'PETER'
    assert_equal 'peter', site.subdomain
  end

  def test_complex_site
    site = Site.new
    default_testing(site)
    refute site.valid?

    site.subdomain = 'PETER'
    assert_equal 'peter', site.subdomain
  end

  def test_validation
    site = Site.new
    [:peter, 'linus', 'Anacletus', '0test', '0', 'test0', 'a' * 63, 'A' * 63].each do | s |
      site.subdomain = s
      assert site.valid?, "Expected #{s} to be a valid subdomain"
    end
    [nil, '_', 'öäü', 'test&', 'test%', '_peter', :peter_, 'a' * 64].each do | s |
      site.subdomain = s
      refute site.valid?, "Expected \"#{s}\" to be an invalid subdomain"
    end
  end

  class UrlTest < ActiveSupport::TestCase
    module UrlFor
      def url_for(*args)
        args
      end
    end

    def acts_as_site_test_site_url(site, options = {})
      options[:site] = site
      url_for(options)
    end

    def acts_as_site_test_site_path(site, options = {})
      options[:site] = site
      options[:only_path] = true
      url_for(options)
    end

    include UrlFor
    include SubdomainSite::UrlFor
    include ActionDispatch::Routing::PolymorphicRoutes

    def current_site
      @current_site ||= Site.new(:peter)
    end

    def test_site_url_different_site
      @actual = polymorphic_url(Site.new(:linus))
      assert_equal [{ subdomain: 'linus', only_path: false }], @actual
    end

    def test_site_path_different_site
      @actual = polymorphic_path(Site.new(:linus))
      assert_equal [{ subdomain: 'linus', only_path: false }], @actual
    end

    def test_site_url_same_site
      @actual = polymorphic_url(current_site)
      assert_equal [{ subdomain: 'peter', only_path: false }], @actual
    end

    def test_site_path_same_site
      @actual = polymorphic_path(current_site)
      assert_equal [{ subdomain: 'peter', only_path: true }], @actual
    end
  end
end
