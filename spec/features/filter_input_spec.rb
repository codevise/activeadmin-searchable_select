require 'rails_helper'

require 'support/models'
require 'support/capybara'
require 'support/active_admin_helpers'

RSpec.describe 'filter input', type: :request do
  describe 'without ajax option' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Post) do
          filter :category, as: :searchable_select
        end
      end
    end

    it 'renders select input with searchable-select-input css class' do
      get '/admin/posts'

      expect(response.body).to have_selector('select.searchable-select-input')
    end

    it 'renders options statically' do
      Category.create!(name: 'Travel')
      Category.create!(name: 'Music')

      get '/admin/posts'

      expect(response.body).to have_selector('.searchable-select-input option', text: 'Travel')
      expect(response.body).to have_selector('.searchable-select-input option', text: 'Music')
    end

    it 'does not set data-ajax-url attribute' do
      get '/admin/posts'

      expect(response.body).not_to have_selector('.searchable-select-input[data-ajax-url]')
    end
  end

  shared_examples 'renders ajax based searchable select input' do
    it 'renders select input with searchable-select-input css class' do
      get '/admin/posts'

      expect(response.body).to have_selector('select.searchable-select-input')
    end

    it 'does not render options statically' do
      Category.create!(name: 'Travel')

      get '/admin/posts'

      expect(response.body).not_to have_selector('.searchable-select-input option', text: 'Travel')
    end

    it 'sets data-ajax-url attribute' do
      get '/admin/posts'

      expect(response.body).to have_selector('.searchable-select-input[data-ajax-url]')
    end

    it 'renders selected option for current value' do
      category = Category.create!(name: 'Travel')

      get "/admin/posts?q[category_id_eq]=#{category.id}"

      expect(response.body).to have_selector('.searchable-select-input option[selected]',
                                             text: 'Travel')
    end
  end

  describe 'with ajax option set to true' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Category) do
          searchable_select_options(scope: Category, text_attribute: :name)
        end

        ActiveAdmin.register(Post) do
          filter(:category,
                 as: :searchable_select,
                 ajax: true)
        end
      end
    end

    include_examples 'renders ajax based searchable select input'
  end

  describe 'with options collection name passed in ajax option' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Category) do
          searchable_select_options(name: 'custom', scope: Category, text_attribute: :name)
        end

        ActiveAdmin.register(Post) do
          filter(:category,
                 as: :searchable_select,
                 ajax: {
                   collection_name: 'custom'
                 })
        end
      end
    end

    include_examples 'renders ajax based searchable select input'
  end

  describe 'with options resource passed in ajax option' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Category) do
          searchable_select_options(scope: Category, text_attribute: :name)
        end

        ActiveAdmin.register(Post) do
          filter(:category_id_eq,
                 as: :searchable_select,
                 ajax: {
                   resource: Category
                 })
        end
      end
    end

    include_examples 'renders ajax based searchable select input'
  end

  describe 'with options resource and collection name passed in ajax option' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Category) do
          searchable_select_options(name: 'custom', scope: Category, text_attribute: :name)
        end

        ActiveAdmin.register(Post) do
          filter(:category_id_eq,
                 as: :searchable_select,
                 ajax: {
                   resource: Category,
                   collection_name: 'custom'
                 })
        end
      end
    end

    include_examples 'renders ajax based searchable select input'
  end

  describe 'with selected option in ajax mode' do
    it 'applies scope when looking up record' do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Category) do
          searchable_select_options(scope: Category.none, text_attribute: :name)
        end

        ActiveAdmin.register(Post) do
          filter(:category, as: :searchable_select, ajax: true)
        end
      end

      category = Category.create!(name: 'Travel')

      get "/admin/posts?q[category_id_eq]=#{category.id}"

      expect(response.body).not_to have_selector('.searchable-select-input option[selected]')
    end

    it 'allows to use view helpers in scope lambda' do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Category) do
          searchable_select_options(scope: -> { Category.where(created_by: current_user) },
                                    text_attribute: :name)
        end

        ActiveAdmin.register(Post) do
          filter(:category, as: :searchable_select, ajax: true)
        end
      end

      user = User.create!
      ApplicationController.current_user = user
      category = Category.create!(name: 'Travel', created_by: user)

      get "/admin/posts?q[category_id_eq]=#{category.id}"

      expect(response.body).to have_selector('.searchable-select-input option[selected]',
                                             text: 'Travel')
    end
  end

  describe 'with the multiple option set to true' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Category) do
          searchable_select_options(scope: Category, text_attribute: :name)
        end

        ActiveAdmin.register(Post) do
          filter(:category,
                 as: :searchable_select,
                 ajax: true,
                 multiple: true)
        end
      end
    end

    it 'renders select input with searchable-select-input css class and the multiple attribute' do
      get '/admin/posts'

      expect(response.body).to have_selector("select.searchable-select-input[multiple='multiple']")
    end

    it 'does not render options statically' do
      Category.create!(name: 'Travel')

      get '/admin/posts'

      expect(response.body).not_to have_selector('.searchable-select-input option',
                                                 text: 'Travel')
    end

    it 'sets data-ajax-url attribute' do
      get '/admin/posts'

      expect(response.body).to have_selector('.searchable-select-input[data-ajax-url]')
    end

    it 'renders the filter for multiple values selected' do
      category1 = Category.create!(name: 'Travel')
      category2 = Category.create!(name: 'Leisure')

      get "/admin/posts?q[category_id_in][]=#{category1.id}&q[category_id_in][]=#{category2.id}"

      expect(response.body).to have_selector('.searchable-select-input option[selected]',
                                             text: 'Travel')
      expect(response.body).to have_selector('.searchable-select-input option[selected]',
                                             text: 'Leisure')
    end
  end
end
