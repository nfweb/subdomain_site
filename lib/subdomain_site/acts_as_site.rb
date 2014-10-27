module SubdomainSite
  module ActsAsSite
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_site(options = {})
        include SubdomainSite::ActsAsSite::LocalInstanceMethods

        options = { subdomain_attr: options } unless options.is_a?(Hash)
        options[:subdomain_attr] ||= :subdomain
        options[:subdomain_attr] = options[:subdomain_attr].to_sym unless options[:subdomain_attr].nil?

        if options[:subdomain_attr]
          class_eval do
            require 'active_model'
            include ActiveModel::Validations

            validates_presence_of options[:subdomain_attr]
            validates_length_of   options[:subdomain_attr], in: 1..63
            validates_format_of   options[:subdomain_attr],
                with: /\A[a-z0-9](?:[a-z0-9\-]{0,61}[a-z0-9])?\z/i,
                message: 'Subdomains must contain only alpha-numericals or hyphens but may neither begin nor end with a hyphen'

            if respond_to? :validates_uniqueness_of
              validates_uniqueness_of options[:subdomain_attr], case_sensitive: false
            end

            define_method "#{options[:subdomain_attr]}_with_downcase=" do |val|
              val = val.to_s.downcase unless val.nil?
              send "#{options[:subdomain_attr]}_without_downcase=", val
            end
            # FIXME: does not work with activerecord
            alias_method_chain "#{options[:subdomain_attr]}=", :downcase if method_defined? "#{options[:subdomain_attr]}="

            define_method :to_param do
              (send options[:subdomain_attr]).to_s
            end
          end
        end

        @subdomain_attr = options[:subdomain_attr]

        # There should usually only be one model representing subsites
        # but this automatic setting interferes with test suites.
        # SubdomainSite.site_model = self
      end

      def find_by_subdomain(subdomain, params = {})
        subdomain.downcase!
        # provide some simple caching since site lookups happen very frequently
        @subdomains ||= {}

        return @subdomains[subdomain] if @subdomains.key?(subdomain) && params.empty?

        @subdomains[subdomain] = find_by(params.merge(@subdomain_attr => subdomain))
      end
    end

    module LocalInstanceMethods
      def site
        self
      end

      def site?
        true
      end

      def site_member?
        true
      end

      def default_url_options
        { subdomain: to_param }
      end
    end
  end

  class DefaultSite
    require 'active_model'
    include ActiveModel::Model
    include SubdomainSite::ActsAsSite

    def persisted?
      true
    end

    def subdomain
      SubdomainSite.default_subdomain
    end
  end
end
