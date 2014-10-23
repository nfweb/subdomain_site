begin
  require "bundler"
  Bundler.setup
rescue LoadError
  $stderr.puts "You need to have Bundler installed to be able build this gem."
end
require 'rake/testtask'

task default: :test

Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true

  t.libs << 'lib'
  t.libs << 'test'
end
