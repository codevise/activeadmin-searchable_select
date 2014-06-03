# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activeadmin/select2/version'

Gem::Specification.new do |spec|
  spec.name          = "activeadmin-select2"
  spec.version       = ActiveAdmin::Select2::VERSION
  spec.summary       = %q{Incorporate Select2 jquery into ActiveAdmin}
  spec.description   = %q{With ActiveAdmin-Select2 you are able to chose Select2 as a drop-down entry option in Forms and Filters}
  spec.license       = "MIT"
  spec.authors       = ["Mark Fairburn"]
  spec.email         = "mark@praxitar,com"
  spec.homepage      = "https://github.com/mfairburn/activeadmin-select2#readme"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency 'activeadmin'
  spec.add_runtime_dependency 'jquery-rails'
  spec.add_runtime_dependency 'select2-rails'

end
