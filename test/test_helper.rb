require 'simplecov'

SimpleCov.start 'rails' do
  enable_coverage :branch
end

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

Rails.root.join('test/support').then do |pathname|
  require pathname.join('regexp_patterns')
  require pathname.join('hash_schema_assertions')
  require pathname.join('todo_assertions')
end

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include HashSchemaAssertions
end
