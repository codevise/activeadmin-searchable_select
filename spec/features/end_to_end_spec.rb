require 'rails_helper'

require 'support/models'
require 'support/capybara'
require 'support/active_admin_helpers'

RSpec.describe 'end to end', type: :feature, js: true do
  context 'class name without namespaces' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Category) do
          searchable_select_options(scope: Category, text_attribute: :name)
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
      it 'loads filter input options' do
        Category.create(name: 'Music')
        Category.create(name: 'Travel')

        visit '/admin/posts'

        expand_select_box
        wait_for_ajax

        expect(select_box_items).to eq(%w(Music Travel))
      end

      it 'allows filtering options by term' do
        Category.create(name: 'Music')
        Category.create(name: 'Travel')

        visit '/admin/posts'

        expand_select_box
        enter_search_term('T')
        wait_for_ajax

        expect(select_box_items).to eq(%w(Travel))
      end

      it 'loads more items when scrolling down' do
        15.times { |i| Category.create(name: "Category #{i}") }
        visit '/admin/posts'

        expand_select_box
        wait_for_ajax
        scroll_select_box_list
        wait_for_ajax

        expect(select_box_items.size).to eq(15)
      end
    end
  end

  context 'class name with namespace' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register RGB::Color, as: 'color' do
          searchable_select_options scope: RGB::Color, text_attribute: :code
        end

        ActiveAdmin.register Internal::TagName, as: 'Tag Name' do
          filter :color, as: :searchable_select, ajax: { resource: RGB::Color }
        end

        ActiveAdmin.setup {}
      end
    end

    describe 'index page with searchable select filter' do
      it 'loads filter input options' do
        RGB::Color.create(code: '#eac112', description: 'Orange')
        RGB::Color.create(code: '#19bf25', description: 'Green')

        visit '/admin/tag_names'

        expand_select_box
        wait_for_ajax

        expect(select_box_items).to eq(%w(#eac112 #19bf25))
      end
    end
  end

  context 'class with nested belongs_to association' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(OptionType)

        ActiveAdmin.register(Product)

        ActiveAdmin.register(OptionValue) do
          belongs_to :option_type
          searchable_select_options(scope: lambda do |params|
                                             OptionValue.where(
                                               option_type_id: params[:option_type_id]
                                             )
                                           end,
                                    text_attribute: :value)
        end

        ActiveAdmin.register(Variant) do
          belongs_to :product

          form do |f|
            input :price
            input(:option_value,
                  as: :searchable_select,
                  path_params: { option_type_id: f.object.product.option_type_id },
                  ajax: {
                    resource: OptionValue
                  })
          end
        end

        ActiveAdmin.setup {}
      end
    end

    describe 'new page with searchable select filter' do
      it 'loads filter input options' do
        option_type = OptionType.create(name: 'Color')
        ot = OptionType.create(name: 'Size')
        OptionValue.create(value: 'Black', option_type: option_type)
        OptionValue.create(value: 'Orange', option_type: option_type)
        OptionValue.create(value: 'M', option_type: ot)
        product = Product.create(name: 'Cap', option_type: option_type)

        visit "/admin/products/#{product.id}/variants/new"

        expand_select_box
        wait_for_ajax

        expect(select_box_items).to eq(%w(Black Orange))
      end

      it 'allows filtering options by term' do
        option_type = OptionType.create(name: 'Color')
        ot = OptionType.create(name: 'Size')
        OptionValue.create(value: 'Black', option_type: option_type)
        OptionValue.create(value: 'Orange', option_type: option_type)
        OptionValue.create(value: 'M', option_type: ot)
        product = Product.create(name: 'Cap', option_type: option_type)

        visit "/admin/products/#{product.id}/variants/new"

        expand_select_box
        enter_search_term('O')
        wait_for_ajax

        expect(select_box_items).to eq(%w(Orange))
      end

      it 'loads more items when scrolling down' do
        option_type = OptionType.create(name: 'Color')
        15.times { |i| OptionValue.create(value: "Black #{i}", option_type: option_type) }
        product = Product.create(name: 'Cap', option_type: option_type)

        visit "/admin/products/#{product.id}/variants/new"

        expand_select_box
        wait_for_ajax
        scroll_select_box_list
        wait_for_ajax

        expect(select_box_items.size).to eq(15)
      end
    end
  end

  def expand_select_box
    find('.select2-container').click
  end

  def enter_search_term(term)
    find('.select2-dropdown input').send_keys(term)
  end

  def scroll_select_box_list
    page.execute_script '$(".select2-container ul").scrollTop(1000)'
  end

  def select_box_items
    all('.select2-dropdown li').map(&:text)
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.1
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end
