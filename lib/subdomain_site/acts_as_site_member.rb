module SubdomainSite
  module ActsAsSiteMember
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_site_member(options = {})
        include SubdomainSite::ActsAsSiteMember::LocalInstanceMethods

        options = { site: options } if options.is_a?(Symbol) || options.is_a?(String)

        options = options.reverse_merge(set_site_from_environment: true, site: :site, force: true)

        class_eval do
          include ActiveModel::Validations
          include ActiveModel::Validations::Callbacks

          require 'active_model/validations/site_validator' # FIXME: does not get loaded by railties
          validates options[:site], site: true
          validates options[:site], presence: true if options[:force]

          if options[:set_site_from_environment]
            insert_after_initialize_callback unless respond_to? :after_initialize

            after_initialize :set_site_from_environment
          end

          # TODO: add site access for descendants of direct site members
          alias_method :site, options[:site].to_sym if options[:site] != :site
        end
      end

      private

      def insert_after_initialize_callback
        class_eval do
          extend ActiveModel::Callbacks
          define_model_callbacks :initialize, only: :after

          def initialize_with_callback(*args)
            run_callbacks :initialize do
              initialize_without_callback(*args)
            end
          end
          alias_method_chain :initialize, :callback
        end
      end
    end

    module LocalInstanceMethods
      def site_member?
        true
      end

      def set_site_from_environment
        self.site ||= SubdomainSite.site
      end
    end
  end
end
