require 'pry'
require 'pathname'
require 'webmock/rspec'
require 'factory_girl'

WebMock.disable_net_connect!(allow_localhost: true)

factories_path = Pathname.new(File.expand_path('..', __FILE__))
factories_path = factories_path.join('factories', '**', '*.rb')
Dir[factories_path].each { |f| require f }

support_path = Pathname.new(File.expand_path('..', __FILE__))
support_path = support_path.join('support', '**', '*.rb')
Dir[support_path].each { |f| require f }

RSpec.configure do |config|
  # Fix for faker deprecation message
  I18n.enforce_available_locales                         = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered                = true
  config.order                                           = 'random'
  config.filter_run           :focus
  config.filter_run_excluding broken: true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
