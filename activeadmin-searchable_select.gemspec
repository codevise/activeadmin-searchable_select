# -*- encoding: utf-8 -*-

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

  spec.required_ruby_version = '~> 2.1'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'appraisal', '~> 2.2'
  spec.add_development_dependency 'rspec-rails', '~> 3.6'
  spec.add_development_dependency 'combustion', '~> 0.7.0'
  spec.add_development_dependency 'database_cleaner', '~> 1.6'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
  spec.add_development_dependency 'capybara', '~> 2.15'
  spec.add_development_dependency 'poltergeist', '~> 1.15'
  spec.add_development_dependency 'rubocop', '~> 0.42.0'
  spec.add_development_dependency 'semmy', '~> 1.0'
  spec.add_development_dependency 'rails'

  spec.add_runtime_dependency 'activeadmin'
  spec.add_runtime_dependency 'jquery-rails'
  spec.add_runtime_dependency 'select2-rails'
end
