require 'rails_helper'

require 'support/models'
require 'support/capybara'
require 'support/active_admin_helpers'

RSpec.describe 'end to end', type: :feature, js: true do
  before(:each) do
    ActiveAdminHelpers.setup do
      ActiveAdmin.register(Category) do
        searchable_select_options(scope: Category, text_method: :name)
      end

      ActiveAdmin.register(Post) do
        filter(:category, as: :searchable_select, ajax: true)

        form do |f|
          f.input(:category, as: :searchable_select, ajax: true)
        end
      end

      ActiveAdmin.setup {}
    end
  end

  describe 'index page with searchable select filter' do
    before(:each) do
      music_category = Category.create(name: 'Music')
      travel_category = Category.create(name: 'Travel')

      Post.create(title: 'Best songs',
                  category: music_category)
      Post.create(title: 'Best places',
                  category: travel_category)
    end

    it 'loads filter input options' do
      visit '/admin/posts'

      expand_select_box

      expect(select_box_items).to eq(%w(Music Travel))
    end

    it 'allows filtering options by term' do
      visit '/admin/posts'

      expand_select_box

      wait_for_ajax do
        enter_search_term('T')
      end

      expect(select_box_items).to eq(%w(Travel))
    end
  end

  def expand_select_box
    find('.select2-container').click
  end

  def enter_search_term(term)
    find('.select2-dropdown input').send_keys(term)
  end

  def select_box_items
    all('.select2-dropdown li').map(&:text)
  end

  def wait_for_ajax(count = 1)
    page.execute_script 'window._ajaxCalls = 0'
    page.execute_script 'window._ajaxCompleteCounter = function() { window._ajaxCalls += 1; }'
    page.execute_script '$(document).ajaxComplete(window._ajaxCompleteCounter)'

    yield

    sleep(0.5) until finished_all_ajax_requests?(count)
  end

  def finished_all_ajax_requests?(count)
    page.evaluate_script('window._ajaxCalls') == count
  end
end
