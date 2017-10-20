require 'rails_helper'

require 'support/models'
require 'support/pluck_polyfill'
require 'support/active_admin_helpers'

RSpec.describe 'searchable_select_options dsl', type: :request do
  describe 'with text_attribute option' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Post) do
          searchable_select_options(scope: Post, text_attribute: :title)
        end
      end
    end

    describe 'creates JSON endpoint that' do
      it 'returns options for searchable select' do
        Post.create!(title: 'A post')

        get '/admin/posts/all_options'

        expect(json_response).to match(results: [a_hash_including(text: 'A post',
                                                                  id: kind_of(Numeric))])
      end

      it 'supports filtering via term parameter' do
        Post.create!(title: 'A post')
        Post.create!(title: 'Other post')
        Post.create!(title: 'Not matched')

        get '/admin/posts/all_options?term=post'
        titles = json_response[:results].pluck(:text)

        expect(titles).to eq(['A post', 'Other post'])
      end

      it 'supports limiting number of results' do
        Post.create!(title: 'A post')
        Post.create!(title: 'Other post')
        Post.create!(title: 'Yet another post')

        get '/admin/posts/all_options?limit=2'

        expect(json_response[:results].size).to eq(2)
      end
    end
  end

  describe 'with separate filter option' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Post) do
          searchable_select_options(scope: Post,
                                    filter: ->(term, scope) { scope.where(title: term) },
                                    text_attribute: :title)
        end
      end
    end

    describe 'creates JSON endpoint that' do
      it 'returns options for searchable select' do
        Post.create!(title: 'A post')

        get '/admin/posts/all_options'

        expect(json_response).to match(results: [a_hash_including(text: 'A post',
                                                                  id: kind_of(Numeric))])
      end

      it 'supports filtering via term parameter' do
        Post.create!(title: 'Post')
        Post.create!(title: 'Not matched')

        get '/admin/posts/all_options?term=Post'
        titles = json_response[:results].pluck(:text)

        expect(titles).to eq(['Post'])
      end

      it 'supports limiting number of results' do
        Post.create!(title: 'A post')
        Post.create!(title: 'Other post')
        Post.create!(title: 'Yet another post')

        get '/admin/posts/all_options?limit=2'

        expect(json_response[:results].size).to eq(2)
      end
    end
  end

  describe 'with separate display_text option' do
    before(:each) do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Post) do
          searchable_select_options(scope: Post,
                                    display_text: ->(record) { record.title.upcase },
                                    text_attribute: :title)
        end
      end
    end

    describe 'creates JSON endpoint that' do
      it 'returns options for searchable select' do
        Post.create!(title: 'A post')

        get '/admin/posts/all_options'

        expect(json_response).to match(results: [a_hash_including(text: 'A POST',
                                                                  id: kind_of(Numeric))])
      end

      it 'supports filtering via term parameter' do
        Post.create!(title: 'A post')
        Post.create!(title: 'Not matched')

        get '/admin/posts/all_options?term=post'
        titles = json_response[:results].pluck(:text)

        expect(titles).to eq(['A POST'])
      end

      it 'supports limiting number of results' do
        Post.create!(title: 'A post')
        Post.create!(title: 'Other post')
        Post.create!(title: 'Yet another post')

        get '/admin/posts/all_options?limit=2'

        expect(json_response[:results].size).to eq(2)
      end
    end
  end

  it 'allows passing lambda as scope' do
    ActiveAdminHelpers.setup do
      ActiveAdmin.register(Post) do
        searchable_select_options(scope: -> { Post.published },
                                  text_attribute: :title)
      end
    end

    Post.create!(title: 'Draft')
    Post.create!(title: 'Published post', published: true)

    get '/admin/posts/all_options'
    titles = json_response[:results].pluck(:text)

    expect(titles).to eq(['Published post'])
  end

  it 'allows passing lambda as scope that uses view helpers' do
    ActiveAdminHelpers.setup do
      ActiveAdmin.register(Post) do
        searchable_select_options(scope: -> { Post.where(user: current_user) },
                                  text_attribute: :title)
      end
    end

    user = User.create!
    Post.create!(title: 'By current user', user: user)
    Post.create!(title: 'By other user', user: User.create!)

    ApplicationController.current_user = user
    get '/admin/posts/all_options'
    titles = json_response[:results].pluck(:text)

    expect(titles).to eq(['By current user'])
  end

  it 'allows passing lambda that takes params argument' do
    ActiveAdminHelpers.setup do
      ActiveAdmin.register(Post) do
        searchable_select_options(scope: ->(params) { Post.where(user_id: params[:user]) },
                                  text_attribute: :title)
      end
    end

    user = User.create!
    Post.create!(title: 'By given user', user: user)
    Post.create!(title: 'By other user', user: User.create!)

    get "/admin/posts/all_options?user=#{user.id}"
    titles = json_response[:results].pluck(:text)

    expect(titles).to eq(['By given user'])
  end

  it 'allows passing name prefix for collection action' do
    ActiveAdminHelpers.setup do
      ActiveAdmin.register(Post) do
        searchable_select_options(name: :some,
                                  scope: Post,
                                  text_attribute: :title)
      end
    end

    Post.create!(title: 'A post')

    get '/admin/posts/some_options'

    expect(json_response).to match(results: array_including(a_hash_including(text: 'A post')))
  end

  it 'fails with helpful message if scope option is missing' do
    expect do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Post) do
          searchable_select_options(text_attribute: :title)
        end
      end
    end.to raise_error(/Missing option: scope/)
  end

  it 'fails with helpful message if display_text are missing' do
    expect do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Post) do
          searchable_select_options(scope: Post,
                                    filter: ->(_term, scope) { scope })
        end
      end
    end.to raise_error(/Missing option: display_text/)
  end

  it 'fails with helpful message if filter option is missing' do
    expect do
      ActiveAdminHelpers.setup do
        ActiveAdmin.register(Post) do
          searchable_select_options(scope: Post,
                                    display_text: ->(_term, scope) { scope })
        end
      end
    end.to raise_error(/Missing option: filter/)
  end

  def json_response
    JSON.parse(response.body).with_indifferent_access
  end
end
