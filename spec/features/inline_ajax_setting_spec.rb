require 'rails_helper'

require 'support/models'
require 'support/capybara'
require 'support/active_admin_helpers'

RSpec.describe 'inline_ajax_options setting', type: :request do
  describe 'when ajax option set to true ' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Category) do
          searchable_select_options(scope: Category, text_method: :name)
        end

        ActiveAdmin.register(Post) do
          form do |f|
            f.input(:category,
                    as: :searchable_select,
                    ajax: true)
          end
        end
      end
    end

    it 'renders all options statically' do
      Category.create!(name: 'Travel')
      Category.create!(name: 'Music')
      Category.create!(name: 'Cooking')

      ActiveAdmin::SearchableSelect.inline_ajax_options = true
      get '/admin/posts/new'

      expect(response.body).to have_selector('.searchable-select-input option',
                                             text: 'Travel')
      expect(response.body).to have_selector('.searchable-select-input option',
                                             text: 'Music')
      expect(response.body).to have_selector('.searchable-select-input option',
                                             text: 'Cooking')
    end
  end
end
