require "action_controller/railtie"
require "action_mailer/railtie"
require "subdomain_site/railtie"

module Dummy
  class Application < Rails::Application
    config.i18n.enforce_available_locales = false
    config.i18n.available_locales = ["en"]
    config.i18n.default_locale = :en

    config.site_model = :site

    config.secret_key_base = '-'
  end
end
