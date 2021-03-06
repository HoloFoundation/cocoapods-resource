# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-resource/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-resource'
  spec.version       = CocoapodsResource::VERSION
  spec.authors       = ['gonghonglou']
  spec.email         = ['gonghonglou@icloud.com']
  spec.description   = %q{Resource file management configuration tool for Pod.}
  spec.summary       = %q{Configure the pod with Preprocessor Macros to get the name of the current Pod at the line of code execution. By default, add configuration to all current Pods.}
  spec.homepage      = 'https://github.com/HoloFoundation/cocoapods-resource'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
