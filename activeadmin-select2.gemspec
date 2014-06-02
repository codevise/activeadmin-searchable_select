# -*- encoding: utf-8 -*-

require File.expand_path('../lib/active_admin/select2/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "activeadmin-select2"
  gem.version       = ActiveAdmin::Select2::VERSION
  gem.summary       = %q{Incorporate Select2 jquery into ActiveAdmin}
  gem.description   = %q{With ActiveAdmin-Select2 you are able to chose Select2 as a drop-down entry option in Forms and Filters}
  gem.license       = "MIT"
  gem.authors       = ["Mark Fairburn"]
  gem.email         = "mark@praxitar,com"
  gem.homepage      = "https://github.com/mfairburn/activeadmin-select2#readme"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'activeadmin'
  gem.add_runtime_dependency 'jquery-rails'
  gem.add_runtime_dependency 'select2-rails'
  gem.add_development_dependency 'bundler', '~> 1.0'
end
