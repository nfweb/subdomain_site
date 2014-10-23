require 'rake/testtask'
require 'isolate/now'
require 'bundler/gem_tasks'

Rake::TestTask.new do |t|
  t.test_files = Dir['test/**/*_test.rb']
  t.verbose = true

  # The default rake test loader is messing up $LOAD_PATH
  t.loader = :direct
  t.libs << '.'
end

task 'test:all' do
  sh 'rake test'
  puts
  sh 'rake test RAILS=4.0'
  puts
  sh 'rake test RAILS=3.2'
end

task default: :test
