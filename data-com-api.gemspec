# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'data-com-api/version'

Gem::Specification.new do |spec|
  spec.name          = "data_com_api"
  spec.version       = DataComApi::VERSION
  spec.authors       = ["Fire-Dragon-DoL"]
  spec.email         = ["francesco.belladonna@gmail.com"]
  spec.description   = %q{Allows to interface with Data.com API ( Salesforce ex Jigsaw )}
  spec.summary       = %q{Allows to interface with Data.com API ( Salesforce ex Jigsaw )}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
