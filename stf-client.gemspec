# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stf/version'

Gem::Specification.new do |spec|
  spec.name     = 'stf-client'
  spec.version  = Stf::VERSION
  spec.authors  = ['Anton Malinskiy']
  spec.email    = ['anton@malinskiy.com']
  spec.summary  = %q{Request devices from Smartphone Test Farm for adb connection}
  spec.homepage = 'https://github.com/Malinskiy/stf-client'
  spec.license  = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']
  spec.executables   = ['stf-client']

  spec.add_runtime_dependency 'gli', '~> 2.17'
  spec.add_runtime_dependency 'ADB', '~> 0.5'
  spec.add_runtime_dependency 'dante', '~> 0.2.0'
  spec.add_runtime_dependency 'dry-container', '~> 0.6.0'
  spec.add_runtime_dependency 'dry-configurable', '~> 0.8.3'
  spec.add_runtime_dependency 'childprocess', '~> 3.0.0'

  # spec.add_runtime_dependency 'pry', '~> 0.10.4'

  spec.add_development_dependency 'bundler', '~> 1.13.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2'
  spec.add_development_dependency 'webmock', '~> 2.1'
  spec.add_development_dependency 'sinatra', '~> 1.4'
  spec.add_development_dependency 'simplecov', '~> 0.9.1'
  spec.add_development_dependency 'simplecov-json', '~> 0.2'
  spec.add_development_dependency 'simplecov-html', '~> 0.8.0'
end
