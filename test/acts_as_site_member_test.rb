require_relative 'test_helper'

require 'subdomain_site/base'
require 'subdomain_site/acts_as_site'
require 'subdomain_site/acts_as_site_member'

class ActsAsSiteMemberTest < ActiveSupport::TestCase
  class Post
    include ActiveModel::Model
    include SubdomainSite::Base
    include SubdomainSite::ActsAsSiteMember
    attr_accessor :site
    acts_as_site_member

    def initialize(site = nil, id = 1)
      @site = site
      @id = id
    end

    def persisted?
      true
    end

    def to_param
      @id
    end
  end

  class Site
    include ActiveModel::Model
    include SubdomainSite::Base
    include SubdomainSite::ActsAsSite
    attr_accessor :subdomain
    acts_as_site :subdomain
    def initialize(subdomain = nil)
      @subdomain = subdomain
    end

    def persisted?
      true
    end
  end

  def default_testing(post)
    assert post.site_member?
    refute post.site?
    assert_respond_to post, :site
  end

  def test_post
    post = Post.new
    default_testing(post)
    refute post.valid?
    post.site = Site.new
    assert post.valid?
  end

  def test_validation
  end

  class UrlTest < ActiveSupport::TestCase
    def acts_as_site_member_test_post_url(post, options = {})
      options[:site] = post.site
      options[:post] = post.to_param
      url_for(options)
    end

    def acts_as_site_member_test_post_path(post, options = {})
      options[:site] = post.site
      options[:post] = post.to_param
      options[:only_path] = true
      url_for(options)
    end

    include SubdomainSite::Test::UrlFor
    include SubdomainSite::UrlFor
    include ActionDispatch::Routing::PolymorphicRoutes

    def current_site
      @current_site ||= Site.new :peter
    end

    def other_site
      @other_site ||= Site.new :linus
    end

    def post_params_url(subdomain, only_path = false)
      { post: @post.to_param, subdomain: subdomain, only_path: only_path }
    end

    def test_url_different_site
      @post = Post.new(other_site)
      @actual = polymorphic_url(@post)
      assert_equal post_params_url('linus'), @actual
    end

    def test_path_different_site
      @post = Post.new(other_site)
      @actual = polymorphic_path(@post)
      assert_equal post_params_url('linus'), @actual
    end

    def test_url_same_site
      @post = Post.new(current_site)
      @actual = polymorphic_url(@post)
      assert_equal post_params_url('peter'), @actual
    end

    def test_path_same_site
      @post = Post.new(current_site)
      @actual = polymorphic_path(@post)
      assert_equal post_params_url('peter', true), @actual
    end
  end
end
