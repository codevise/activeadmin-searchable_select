require 'rails_helper'

require 'support/models'
require 'support/capybara'
require 'support/active_admin_helpers'

RSpec.describe 'ajax params', type: :request do
  before(:each) do
    ActiveAdminHelpers.setup do
      ActiveAdmin.register(Category) do
        searchable_select_options(scope: lambda do |params|
                                           Category.where(created_by_id: params[:created_by])
                                         end,
                                  text_attribute: :name)
      end

      ActiveAdmin.register(Post) do
        form do |f|
          f.input(:category,
                  as: :searchable_select,
                  ajax: {
                    params: {
                      created_by: current_user.id
                    }
                  })
        end
      end
    end
  end

  it 'passes parameters when rendering selected item' do
    user = User.create
    category = Category.create(name: 'Travel', created_by: user)
    post = Post.create(category: category)

    ApplicationController.current_user = user
    get "/admin/posts/#{post.id}/edit"

    expect(response.body).to have_selector('.searchable-select-input option[selected]',
                                           text: 'Travel')
  end

  it 'includes parameters in ajax url' do
    user = User.create

    ApplicationController.current_user = user
    get '/admin/posts/new'

    url_matcher = "?created_by=#{user.id}"
    expect(response.body).to have_selector('.searchable-select-input' \
                                           "[data-ajax-url*='#{url_matcher}']")
  end

  context 'when using belongs_to' do
    before(:each) do
      ActiveAdminHelpers.setup do

        ActiveAdmin.register(OptionType)

        ActiveAdmin.register(Product) do

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
            f.input(:option_value,
                    as: :searchable_select,
                    ajax: {
                      resource: OptionValue,
                      path_params: {
                        option_type_id: f.object.product.option_type_id
                      }
                    })
          end
        end
      end
    end

    it 'pre-select items in the associations' do 
      option_type = OptionType.create
      product = Product.create(option_type: option_type)
      option_value = OptionValue.create(option_type: option_type, value: 'Red')
      variant = Variant.create(product: product, option_value: option_value)

      get "/admin/products/#{product.id}/variants/#{variant.id}/edit"
  
      expect(response.body).to have_selector('.searchable-select-input option[selected]',
        count: 1)
    end
  end
end
