require 'rails_helper'

require 'support/models'
require 'support/capybara'
require 'support/active_admin_helpers'

RSpec.describe 'dependent selects' do
  let!(:italy) { Country.create!(name: 'Italy') }
  let!(:germany) { Country.create!(name: 'Germany') }
  let!(:genoa) { City.create!(name: 'Genoa', country: italy) }
  let!(:naples) { City.create!(name: 'Naples', country: italy) }
  let!(:livorno) { City.create!(name: 'Livorno', country: italy) }
  let!(:hamburg) { City.create!(name: 'Hamburg', country: germany) }
  let(:object_name) { 'trip' }

  context 'on belongs_to associations' do
    before(:each) do
      register_trip_admin do
        filter(:country, as: :searchable_select, ajax: true, multiple: true)
        filter(:origin, as: :searchable_select, depends_on: :country)

        form do |f|
          f.input(:country, as: :searchable_select, ajax: true)
          f.input(:origin, as: :searchable_select, depends_on: :country)
          f.input(:destination,
                  as: :searchable_select,
                  ajax: { collection_name: :destinations },
                  depends_on: [:country, :origin])
        end
      end
    end

    describe 'form', type: :request do
      it 'implies ajax and points to the inputs it depends on' do
        get '/admin/trips/new'

        expect(response.body).to have_selector(
          'select[name="trip[origin_id]"]' \
          '[data-ajax-url="/admin/cities/all_options?"]' \
          '[data-searchable-select-depends-on=\'{"country":"trip[country_id]"}\']'
        )
        expect(response.body).to have_selector(
          'select[name="trip[destination_id]"]' \
          '[data-searchable-select-depends-on=\'{"country":"trip[country_id]",' \
          '"origin":"trip[origin_id]"}\']'
        )
      end

      it 'passes the values it depends on to the scope when rendering selected items' do
        trip = Trip.create!(country: italy, origin: genoa, destination: naples)

        get "/admin/trips/#{trip.id}/edit"

        expect(response.body).to have_selector('select[name="trip[origin_id]"]' \
                                               ':not([disabled]) option[selected]', text: 'Genoa')
        expect(response.body).to have_selector('select[name="trip[destination_id]"]' \
                                               ':not([disabled]) option[selected]', text: 'Naples')
      end
    end

    describe 'filter', type: :request do
      it 'points to the filter it depends on and is disabled until it is chosen' do
        get '/admin/trips'

        expect(response.body).to have_selector(
          'select[name="q[origin_id_eq]"][disabled]' \
          '[data-searchable-select-depends-on=\'{"country":"q[country_id_in][]"}\']'
        )
      end

      it 'is enabled and renders the selected item once the filter it depends on is set' do
        get '/admin/trips', params: { q: { country_id_in: [italy.id], origin_id_eq: genoa.id } }

        expect(response.body).to have_selector('select[name="q[origin_id_eq]"]' \
                                               ':not([disabled]) option[selected]', text: 'Genoa')
      end
    end

    describe 'in the browser', type: :feature, js: true do
      it 'enables, scopes and resets the chain of selects' do
        visit '/admin/trips/new'

        expect(select_input('origin_id')).to be_disabled
        expect(select_input('destination_id')).to be_disabled

        choose_option('country_id', 'Italy')

        expect(select_input('origin_id')).not_to be_disabled
        expect(select_input('destination_id')).to be_disabled
        expect(options_of('origin_id')).to eq(%w(Genoa Naples Livorno))

        choose_option('origin_id', 'Genoa')

        expect(select_input('destination_id')).not_to be_disabled
        expect(options_of('destination_id')).to eq(%w(Naples Livorno))

        choose_option('destination_id', 'Naples')
        choose_option('country_id', 'Germany')

        expect(select_input('origin_id')).not_to be_disabled
        expect(select_input('origin_id').value).to eq('')
        expect(select_input('destination_id')).to be_disabled
        expect(select_input('destination_id').value).to eq('')
        expect(options_of('origin_id')).to eq(%w(Hamburg))
      end
    end
  end

  context 'on has_many :through associations' do
    before(:each) do
      register_trip_admin do
        config.comments = false
        permit_params(:country_id, :destination_id, stop_ids: [])

        filter(:country, as: :searchable_select, ajax: true)
        filter(:stops, as: :searchable_select, depends_on: :country)
        filter(:destination,
               as: :searchable_select,
               ajax: { collection_name: :among_stops },
               depends_on: :stops)

        form do |f|
          f.input(:country, as: :searchable_select, ajax: true)
          f.input(:stops, as: :searchable_select, depends_on: :country)
          f.input(:destination,
                  as: :searchable_select,
                  ajax: { collection_name: :among_stops },
                  depends_on: :stops)
          f.actions
        end
      end
    end

    describe 'form', type: :request do
      it 'renders a disabled multi-select that points to the inputs it depends on' do
        get '/admin/trips/new'

        expect(response.body).to have_selector(
          'select[name="trip[stop_ids][]"][multiple][disabled]' \
          '[data-searchable-select-depends-on=\'{"country":"trip[country_id]"}\']'
        )
        expect(response.body).to have_selector(
          'select[name="trip[destination_id]"][disabled]' \
          '[data-searchable-select-depends-on=\'{"stops":"trip[stop_ids][]"}\']'
        )
      end

      it 'passes the values it depends on to the scope when rendering selected items' do
        trip = Trip.create!(country: italy, stops: [genoa, livorno], destination: livorno)

        get "/admin/trips/#{trip.id}/edit"

        expect(response.body).to have_selector('select[name="trip[stop_ids][]"]' \
                                               ':not([disabled]) option[selected]', text: 'Genoa')
        expect(response.body).to have_selector('select[name="trip[stop_ids][]"]' \
                                               ':not([disabled]) option[selected]', text: 'Livorno')
        expect(response.body).to have_selector('select[name="trip[destination_id]"]' \
                                               ':not([disabled]) option[selected]', text: 'Livorno')
      end
    end

    describe 'filter', type: :request do
      it 'points to filters named after the join model and is disabled until they are chosen' do
        get '/admin/trips'

        expect(response.body).to have_selector(
          'select[name="q[trip_stops_city_id_eq]"][disabled]' \
          '[data-searchable-select-depends-on=\'{"country":"q[country_id_eq]"}\']'
        )
        expect(response.body).to have_selector(
          'select[name="q[destination_id_eq]"][disabled]' \
          '[data-searchable-select-depends-on=\'{"stops":"q[trip_stops_city_id_eq]"}\']'
        )
      end

      it 'is enabled and renders the selected items once the filters it depends on are set' do
        get '/admin/trips', params: { q: { country_id_eq: italy.id,
                                           trip_stops_city_id_eq: genoa.id,
                                           destination_id_eq: genoa.id } }

        expect(response.body).to have_selector('select[name="q[trip_stops_city_id_eq]"]' \
                                               ':not([disabled]) option[selected]', text: 'Genoa')
        expect(response.body).to have_selector('select[name="q[destination_id_eq]"]' \
                                               ':not([disabled]) option[selected]', text: 'Genoa')
      end
    end

    describe 'in the browser', type: :feature, js: true do
      it 'passes multiple values down the chain and resets them' do
        visit '/admin/trips/new'

        expect(select_input('stop_ids')).to be_disabled
        expect(select_input('destination_id')).to be_disabled

        choose_option('country_id', 'Italy')

        expect(select_input('stop_ids')).not_to be_disabled
        expect(select_input('destination_id')).to be_disabled
        expect(options_of('stop_ids')).to eq(%w(Genoa Naples Livorno))

        choose_option('stop_ids', 'Genoa')
        choose_option('stop_ids', 'Livorno')

        expect(select_input('destination_id')).not_to be_disabled
        expect(options_of('destination_id')).to eq(%w(Genoa Livorno))

        choose_option('destination_id', 'Livorno')
        choose_option('country_id', 'Germany')

        expect(select_input('stop_ids')).not_to be_disabled
        expect(select_input('stop_ids').value).to eq([])
        expect(select_input('destination_id')).to be_disabled
        expect(select_input('destination_id').value).to eq('')
        expect(options_of('stop_ids')).to eq(%w(Hamburg))
      end

      it 'saves the reset inputs as blank' do
        trip = Trip.create!(country: italy, stops: [genoa, livorno], destination: livorno)

        visit "/admin/trips/#{trip.id}/edit"
        choose_option('country_id', 'Germany')
        click_button 'Update Trip'

        expect(page).to have_content('Trip was successfully updated')
        expect(trip.reload.stops).to be_empty
        expect(trip.destination).to be_nil
      end

      it 'clears values of an untouched chain whose parent is blank' do
        trip = Trip.create!(stops: [genoa], destination: genoa)

        visit "/admin/trips/#{trip.id}/edit"
        click_button 'Update Trip'

        expect(page).to have_content('Trip was successfully updated')
        expect(trip.reload.stops).to be_empty
        expect(trip.destination).to be_nil
      end
    end
  end

  context 'on a country from another table' do
    before(:each) do
      register_trip_admin do
        filter(:organization_country, as: :searchable_select, ajax: true)
        filter(:stops, as: :searchable_select, depends_on: { country: :organization_country })
        filter(:destination,
               as: :searchable_select,
               depends_on: { country: :organization_country_id })
      end
    end

    describe 'filter', type: :request do
      it 'points to the filter on the other table' do
        get '/admin/trips'

        expect(response.body).to have_selector(
          'select[name="q[organization_country_id_eq]"]:not([disabled])'
        )
        expect(response.body).to have_selector(
          'select[name="q[trip_stops_city_id_eq]"][disabled]' \
          '[data-searchable-select-depends-on=\'{"country":"q[organization_country_id_eq]"}\']'
        )
        expect(response.body).to have_selector(
          'select[name="q[destination_id_eq]"][disabled]' \
          '[data-searchable-select-depends-on=\'{"country":"q[organization_country_id_eq]"}\']'
        )
      end

      it 'passes its value under the given name when rendering selected items' do
        get '/admin/trips', params: { q: { organization_country_id_eq: italy.id,
                                           trip_stops_city_id_eq: genoa.id,
                                           destination_id_eq: naples.id } }

        expect(response.body).to have_selector('select[name="q[trip_stops_city_id_eq]"]' \
                                               ':not([disabled]) option[selected]', text: 'Genoa')
        expect(response.body).to have_selector('select[name="q[destination_id_eq]"]' \
                                               ':not([disabled]) option[selected]', text: 'Naples')
      end
    end

    describe 'in the browser', type: :feature, js: true do
      let(:object_name) { 'q' }

      it 'passes its value under the given name when fetching options' do
        visit '/admin/trips'

        expect(select_input('trip_stops_city_id_eq')).to be_disabled

        choose_option('organization_country_id_eq', 'Italy')

        expect(options_of('trip_stops_city_id_eq')).to eq(%w(Genoa Naples Livorno))
        expect(options_of('destination_id_eq')).to eq(%w(Genoa Naples Livorno))

        choose_option('organization_country_id_eq', 'Germany')

        expect(options_of('trip_stops_city_id_eq')).to eq(%w(Hamburg))
      end
    end
  end

  context 'with a regular select parent using a custom name' do
    before(:each) do
      register_trip_admin do
        form do |f|
          f.input(:country, as: :select, collection: Country.all,
                            input_html: { name: 'trip[chosen_country]' })
          f.input(:origin, as: :searchable_select, depends_on: :country)
        end
      end
    end

    it 'uses the rendered parent name', type: :request do
      get '/admin/trips/new'

      expect(response.body).to have_selector(
        'select[name="trip[origin_id]"]' \
        '[data-searchable-select-depends-on=\'{"country":"trip[chosen_country]"}\']'
      )
    end

    it 'enables and scopes the dependent select', type: :feature, js: true do
      visit '/admin/trips/new'

      expect(select_input('origin_id')).to be_disabled
      select('Italy', from: 'trip_country_id')

      expect(select_input('origin_id')).not_to be_disabled
      expect(options_of('origin_id')).to eq(%w(Genoa Naples Livorno))
    end

    it 'resolves the parent when it renders after the dependent', type: :feature, js: true do
      register_trip_admin do
        form do |f|
          f.input(:origin, as: :searchable_select, depends_on: :country)
          f.input(:country, as: :select, collection: Country.all,
                            input_html: { name: 'trip[chosen_country]' })
        end
      end

      visit '/admin/trips/new'
      select('Italy', from: 'trip_country_id')

      expect(select_input('origin_id')).not_to be_disabled
      expect(options_of('origin_id')).to eq(%w(Genoa Naples Livorno))
    end
  end

  context 'when a dependent filter precedes its multiple parent' do
    let(:object_name) { 'q' }

    before(:each) do
      register_trip_admin do
        filter(:origin, as: :searchable_select, depends_on: :country)
        filter(:country, as: :searchable_select, ajax: true, multiple: true)
      end
    end

    it 'uses the configured parent name and selected value', type: :request do
      get '/admin/trips', params: { q: { country_id_in: [italy.id], origin_id_eq: genoa.id } }

      expect(response.body).to have_selector(
        'select[name="q[origin_id_eq]"]:not([disabled])' \
        '[data-searchable-select-depends-on=\'{"country":"q[country_id_in][]"}\']' \
        ' option[selected]', text: 'Genoa'
      )
    end

    it 'uses a custom parent input name', type: :request do
      register_trip_admin do
        filter(:origin, as: :searchable_select, depends_on: :country)
        filter(:country,
               as: :searchable_select,
               ajax: true,
               input_html: -> { { name: 'q[selected_countries]' } })
      end

      get '/admin/trips'

      expect(response.body).to have_selector('select[name="q[selected_countries]"]')
      expect(response.body).to have_selector(
        'select[name="q[origin_id_eq]"]' \
        '[data-searchable-select-depends-on=\'{"country":"q[selected_countries]"}\']'
      )
    end

    it 'enables the dependent after choosing the parent', type: :feature, js: true do
      visit '/admin/trips'

      expect(select_input('origin_id_eq')).to be_disabled
      choose_option('country_id_in', 'Italy')

      expect(select_input('origin_id_eq')).not_to be_disabled
      expect(options_of('origin_id_eq')).to eq(%w(Genoa Naples Livorno))
    end
  end

  context 'with a read-only parent' do
    before(:each) do
      register_trip_admin do
        config.comments = false
        permit_params(:country_id, :destination_id, stop_ids: [])

        form do |f|
          f.input(:country, as: :searchable_select, ajax: true, input_html: { disabled: true })
          f.input(:stops, as: :searchable_select, depends_on: :country)
          f.input(:destination,
                  as: :searchable_select,
                  ajax: { collection_name: :among_stops },
                  depends_on: :stops)
          f.actions
        end
      end
    end

    it 'keeps the dependent values it shows when saved', type: :feature, js: true do
      trip = Trip.create!(country: italy, stops: [genoa, livorno], destination: livorno)

      visit "/admin/trips/#{trip.id}/edit"
      click_button 'Update Trip'

      expect(page).to have_content('Trip was successfully updated')
      expect(trip.reload.stops).to match_array([genoa, livorno])
      expect(trip.destination).to eq(livorno)
    end
  end

  def register_trip_admin(&block)
    ActiveAdminHelpers.setup do
      ActiveAdmin.register(Country) do
        searchable_select_options(scope: Country, text_attribute: :name)
      end

      ActiveAdmin.register(City) do
        searchable_select_options(scope: ->(params) { City.where(country_id: params[:country]) },
                                  text_attribute: :name)

        searchable_select_options(name: :destinations,
                                  scope: lambda do |params|
                                    City.where(country_id: params[:country])
                                        .where.not(id: params[:origin])
                                  end,
                                  text_attribute: :name)

        searchable_select_options(name: :among_stops,
                                  scope: ->(params) { City.where(id: params[:stops]) },
                                  text_attribute: :name)
      end

      ActiveAdmin.register(Trip, &block)

      ActiveAdmin.setup {}
    end
  end

  def select_input(field)
    find("select[name^='#{object_name}[#{field}]']", visible: :all)
  end

  def options_of(field)
    open_select_box(field)
    items = all('.select2-results__option').map(&:text)
    find('.select2-container--open .select2-search__field').send_keys(:escape)
    items
  end

  def choose_option(field, text)
    open_select_box(field)
    find('.select2-results__option', text: text).click
  end

  def open_select_box(field)
    find("select[name^='#{object_name}[#{field}]'] + .select2-container .select2-selection").click
    wait_for_ajax
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.1
      loop until page.evaluate_script('jQuery.active').zero?
    end
  end
end
