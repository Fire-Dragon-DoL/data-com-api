require 'pry'
require 'factory_girl'
require 'factories'

RSpec.configure do |config|
  # Fix for faker deprecation message
  I18n.enforce_available_locales                         = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered                = true
  config.filter_run :focus
  config.order                                           = 'random'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
