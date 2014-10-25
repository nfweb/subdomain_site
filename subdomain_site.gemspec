# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'subdomain_site'
  spec.version       = '0.0.1'
  spec.authors       = ['Johannes Müller', 'Semyon Perepelitsa']
  spec.email         = ['straightshoota@gmail.com', 'sema@sema.in']
  spec.summary       = 'Subdomains based on model (Rails plugin).'
  spec.description   = 'This gem enables model based subdomains for a rails 4 app.'
  spec.homepage      = 'https://github.com/nfweb/subdomain_site'
  spec.license       = 'MIT'

  spec.files         = %w(Gemfile LICENSE.txt Rakefile Readme.md)
  spec.files         += Dir['lib/**/*.rb']
  spec.files         += Dir['test/**/*']
  spec.test_files    = spec.files.grep(/^test\//)

  spec.add_dependency 'activemodel', '~>4.1'
end

