# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'axel/version'

Gem::Specification.new do |gem|
  gem.name          = "axel"
  gem.version       = Axel::VERSION
  gem.authors       = ["Jon Phenow"]
  gem.email         = ["jon.phenow@sportngin.com"]
  gem.description   = %q{Building blocks and general helpers for platform services}
  gem.summary       = %q{Consistent controller responses, Resources for querying other services consistently, along with some general app support}
  gem.homepage      = "http://github.com/sportngin/axel"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rake', "~> 10.0.3"
  gem.add_development_dependency 'rspec-rails', "~> 2.14"
  gem.add_development_dependency 'rspec-its'
  gem.add_development_dependency 'rspec-collection_matchers'
  gem.add_development_dependency 'pry-rails'
  gem.add_development_dependency 'awesome_print', "~> 1.1.0"
  gem.add_development_dependency 'sqlite3', "~> 1.3.6"
  gem.add_development_dependency 'simplecov', "~> 0.7.1"

  gem.add_development_dependency 'activerecord', '> 3.0'
  gem.add_development_dependency 'gemfury'

  gem.add_dependency 'activesupport', "> 3.0"
  gem.add_dependency 'actionpack', "> 3.0", "< 4.2"
  gem.add_dependency 'railties', "> 3.0"

  gem.add_dependency 'rabl', "~> 0.7.9"
  gem.add_dependency 'jbuilder', ">= 0.9.0"
  gem.add_dependency 'oj', "~> 2.0.0"
  gem.add_dependency 'ffi', ">= 1.0.0"
  gem.add_dependency 'typhoid', "~> 0.0.2"
  gem.add_dependency 'json'
end
