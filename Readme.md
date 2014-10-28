# Rails Subdomain Site

This gem enables model based subdomains for a rails app.
It was inspired by [semaperepelitsa/subdomain_locale](https://github.com/semaperepelitsa/subdomain_locale) gem.

[![Build Status](https://travis-ci.org/nfweb/subdomain_site.svg?branch=master)](https://travis-ci.org/nfweb/subdomain_site)
[![Code Climate](https://codeclimate.com/github/nfweb/subdomain_site/badges/gpa.svg)](https://codeclimate.com/github/nfweb/subdomain_site)

## Setup

Add the gem to your Gemfile.

Set a reference to the site model in your application configuration.

```ruby
# config/application.rb
config.site_model = Site

# optional: set a default site. It is important to write as lambda to be lazy loaded
config.default_site = -> { Site.first }
```

### Site Model
Your model ist set up quite easily, just include ``acts_as_site`` in your ActiveRecord (or ActiveModel) class.

```ruby
class Site < ActiveRecord::Base
  acts_as_site

  # use a different attribute for subdomain
  acts_as_site :slug
end
```

SubdomainSite will by default use the attribute ``#subdomain`` to store the subdomain value, but you may provide a different attribute as parameter to ``acts_as_site``.

You might want to override the following instance methods
* ``#default_url_options``: provides default url options for the site. Return value should include ```:subdomain`` key

### Member Model
``acts_as_site_member`` lets you define a model whose content belongs to a site and is therefore bound to the subdomain.

```ruby
class Post < ActiveRecord::Base
  has_one :site
  acts_as_site_member

  # use a different attribute for site
  has_one :parent
  acts_as_site_member :parent
end
```

### Routing
Add a subdomain constraint to your routing file. You may use ``SubdomainSite::Constraint`` or implement your own subdomain matcher.

```ruby
MyApp::Application.routes.draw do
  constraints SubdomainSite::Constraint.new do
    resources 'post'
    get '/', 'site#show', as: 'site'
  end
end
```

The usual url helpers (``url_for``, ``#{model}_url``) will automatically include the subdomain if you provide a site or site member object as argument.

### Controller

Inside your controller the current site is accesible through the helper ```current_site```.

## Testing

This gem is tested against Rails 4.1.

Could not run on Rails 4.0 because of some dependency conflict with tzinfo-data.
It should also run with Rails 3.2 without major difficulties, just have to change the active model integration.

```
gem install bundler
rake test
```

## Notable Other Solutions
* [consolo/acts_as_restricted_subdomain](https://github.com/consolo/acts_as_restricted_subdomain) (Rails 3.1)
* [fortuity/subdomain-authentication](https://github.com/fortuity/subdomain-authentication) (Rails 2.3)

## Changelog

0.0.1 Initial release

### ```subdomain_locale```
1.1.0

* Custom subdomain provided in your default_url_options now has precedence over the default subdomain-locale.

1.0.0

* Links outside controllers now also point to the current locale. For example, in mailers.
* Now compatible with the new I18n.enforce\_available\_locales.
* No subdomain is now deafult instead of "www". Can be reverted by setting config.default\_domain.
* Separate website's default locale (config.default\_locale) from the global default locale (config.i18n.default\_locale).
* Test gem in the whole Rails stack (3.2, 4.0).
* Add config.subdomain_local for indirect mapping ("us" => :"en-US").

0.1.1

* Adding changelog to the readme.
* Don't require files until they needed. That means less boot time impact.

0.1.0. Minor internal changes & fixes, documentation.

* Fixing url_for's argument modified.
* Adding readme and documentation.
* Using require instead of autoload.
* Refactoring tests.
* Clearly specifying I18n dependency.

0.0.1—0.0.3. Initial releases.

