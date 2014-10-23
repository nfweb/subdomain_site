module SubdomainSite
  module ActsAsSiteMember
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_site_member(options = {})
        include SubdomainSite::ActsAsSiteMember::LocalInstanceMethods

        options = { :site => options } if options.is_a?(Symbol) or options.is_a?(String)

        options[:site] ||= :site

        class_eval do
          require 'active_model'
          include ActiveModel::Validations

          validates_presence_of options[:site]

          alias_method :site, options[:site].to_sym if options[:site] != :site

        end
      end
    end

    module LocalInstanceMethods
      def site_member?
        true
      end
    end
  end
end