# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'data-com-api/version'

Gem::Specification.new do |spec|
  spec.name          = "data-com-api"
  spec.version       = DataComApi::VERSION
  spec.authors       = ["Fire-Dragon-DoL"]
  spec.email         = ["francesco.belladonna@gmail.com"]
  spec.description   = <<-eos
    Allows to interface with Data.com API ( Salesforce, ex Jigsaw )
  eos
  spec.summary       = <<-eos
    Allows to interface with Data.com API ( Salesforce, ex Jigsaw )
  eos
  spec.homepage      = "https://github.com/Fire-Dragon-DoL/data-com-api"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'httparty', '~> 0.12.0'

  spec.add_development_dependency 'rspec',              '~> 2.14'
  spec.add_development_dependency 'rspec-mocks',        '~> 2.14'
  spec.add_development_dependency 'rspec-expectations', '~> 2.14'
  spec.add_development_dependency 'factory_girl',       '~> 4.3'
  spec.add_development_dependency 'faker',              '~> 1.2'
  spec.add_development_dependency 'webmock',            '~> 1.17'
  spec.add_development_dependency 'bundler',            '~> 1.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-debugger'
  spec.add_development_dependency 'rake'
end
