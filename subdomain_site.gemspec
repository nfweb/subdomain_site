# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "subdomain_site"
  spec.version       = "0.0.1"
  spec.authors       = ["Semyon Perepelitsa", "Johannes Müller"]
  spec.email         = ["sema@sema.in", "straightshoota@gmail.com"]
  spec.summary       = "Subdomains based on model (Rails plugin)."
  spec.homepage      = "https://github.com/nfweb/subdomain_site"
  spec.license       = "MIT"

  spec.files         = File.read("Manifest.txt").split("\n")
  spec.test_files    = spec.files.grep(%r{^test/})

  spec.add_dependency "active_model"
end
