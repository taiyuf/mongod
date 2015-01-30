# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongod/version'

Gem::Specification.new do |spec|
  spec.name          = 'mongod'
  spec.version       = Mongod::VERSION
  spec.authors       = ['Taiyu Fujii']
  spec.email         = ['tf.900913@gmail.com']
  spec.summary       = %q{Simple Object-relational mapping gem for Mongo DB on Rails 4.}
  spec.description   = %q{Pagination enabled.}
  spec.homepage      = 'https://github.com/taiyuf'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
  spec.add_development_dependency 'mongo'
  spec.add_development_dependency 'bson'
  spec.add_development_dependency 'activerecord', '~> 4.0.0'
  # spec.add_development_dependency 'rails', '~> 4.0.0'
end
