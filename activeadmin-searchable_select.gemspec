lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activeadmin/searchable_select/version'

Gem::Specification.new do |spec|
  spec.name          = 'activeadmin-searchable_select'
  spec.version       = ActiveAdmin::SearchableSelect::VERSION
  spec.summary       = 'Use searchable selects based on Select2 in Active Admin forms and filters.'
  spec.license       = 'MIT'
  spec.authors       = ['Codevise Solutions Ltd']
  spec.email         = 'info@codevise.de'
  spec.homepage      = 'https://github.com/codevise/activeadmin-searchable_select'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.required_ruby_version = ['>= 2.1', '< 4']

  spec.add_development_dependency 'bundler', ['>= 1.5', '< 3']
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'appraisal', '~> 2.2'
  spec.add_development_dependency 'rspec-rails', '~> 3.6'
  spec.add_development_dependency 'combustion', '~> 1.0'
  spec.add_development_dependency 'database_cleaner', '~> 1.6'
  spec.add_development_dependency 'sqlite3', '~> 1.3'

  spec.add_development_dependency 'capybara', '~> 3.9'
  spec.add_development_dependency 'puma', '~> 5.0'
  spec.add_development_dependency 'selenium-webdriver', '~> 4.1'
  spec.add_development_dependency 'webdrivers', '= 5.3.0'

  spec.add_development_dependency 'coffee-rails'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'rubocop', '~> 0.42.0'
  spec.add_development_dependency 'semmy', '~> 1.0'
  spec.add_development_dependency 'sprockets', '~> 3.7'

  spec.add_runtime_dependency 'activeadmin', ['>= 1.x', '< 4']
  spec.add_runtime_dependency 'jquery-rails', ['>= 3.0', '< 5']
  spec.add_runtime_dependency 'select2-rails', '~> 4.0'
end
