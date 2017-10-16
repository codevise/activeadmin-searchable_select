# ActiveAdmin Searchable Select

Searchable select boxes (via [Select2](https://select2.org/) for
ActiveAdmin forms and filters. Extends the ActiveAdmin resource DSL to
allow defining JSON endpoints to fetch options from asynchronoulsy.

## Installation

Ensure `activeadmin`, `jquery-rails` and `select2-rails` are part of
your Gemfile:

```ruby
   gem 'activeadmin'
   gem 'jquery-rails'
   gem 'select2-rails'
```

Add `activeadmin-searchable_select` to your Gemfile:

```ruby
   gem 'activeadmin-searchable_select
```

Import stylesheets and require javascripts:

```
// active_admin.css.scss

@import "active_admin/searchable_select";
```

```
# active_admin.js.coffee

#= require active_admin/searchable_select
```

## Usage

### Making Select Boxes Searchable

To add search functionality to a select box, use the
`:searchable_select` input type:

```ruby
   ActiveAdmin.register Product do
     form do |f|
       f.input(:category, as: :searchable_select)
     end
   end
```

This also works for filters:

```ruby
   ActiveAdmin.register Product do
     filter(:category, as: :searchable_select)
   end
```

### Fetching Options via Ajax

For large collections, rendering the whole set of options can be to
expensive. Use the `ajax` option to fetch a set of matching options
once the user begins to type:

```ruby

   ActiveAdmin.register Product do
     filter(:category,
            as: :searchable_select,
            ajax: true)
   end
```

If the input attribute corresponds to an ActiveAdmin resource, it is
expected to provide the JSON endpoint that provides the options. Use
the `searchable_select_options` method to define the required
collection action:

```ruby
   ActiveAdmin.register Category do
     searchable_select_options(scope: Category.all,
                               text_method: :name)
   end
```

The `scope` and `text_method` options are required. `scope` needs to
be a Ransack enabled ActiveRecord collection proxy determining which
options are available. The method given by `text_method` will be
called for each record to get the display name for the
option. Filtering by search term and limiting result set size is
handled automatically.

`scope` can also be a lambda which is evaluated in the context of the
collection action defined by the helper:

```ruby
   ActiveAdmin.register Category do
     searchable_select_options(scope: -> { Category.allowed_for(current_user) },
                               text_method: :name)
   end
```

If the input attribute is set on the form's object, ajax based
searchable selects will automatically render a single option to ensure
the selected item is displayed correctly even before options have been
loaded asynchronously.

#### Specifying the Options Endpoint Resource

If the resource that provides the options endpoint cannot be guessed
based on the input attribute name, you can pass an object with a
`resource` key as `ajax` option:

```ruby
   ActiveAdmin.register Product do
     form do |f|
       f.input(:additional_category,
               as: :searchable_select,
               ajax: { resource: Category })
     end
   end
```

#### Mutlple Options Endpoints per Resource

A single ActiveAdmin resource can define multiple options endpoints:

```ruby
   ActiveAdmin.register Category do
     searchable_select_options(name: :favorites,
                               scope: Category.favorites,
                               text_method: :name)

     searchable_select_options(name: :recent,
                               scope: Category.recent,
                               text_method: :name)
   end
```

To specify which collection to use, pass an object with a
`collection_name` key as `ajax` option:

```ruby
   ActiveAdmin.register Product do
     form do |f|
        f.input(:category,
                as: :searchable_select,
                ajax: { collection_name: :favorites })
     end
   end
```

#### Passing Parameters

You can pass additional parameters to the options endpoint:

```ruby
   ActiveAdmin.register Product do
     form do |f|
        f.input(:category,
                as: :searchable_select,
                ajax: {
                  params: {
                    some: 'value'
                  }
                })
     end
   end
```

The lambda passed as `scope` can receive those parameters as first
argument:

```ruby
   ActiveAdmin.register Category do
     searchable_select_options(scope: lambda do |params|
                                 Category.find_all_by_some(params[:some])
                               end,
                               text_method: :name)
   end
```

#### Inlining Ajax Options in Feature Tests

When writing UI driven feature specs (i.e. with Capybara),
asynchronous loading of select options can increase test
complexity. `activeadmin-searchable_select` provides an option to
render all available options just like a normal select input while
still exercsing the same code paths including `scope` and
`text_method` handling.

For example with RSpec/Capybara, simply set `inline_ajax_options` true
for feature specs:

```ruby
  RSpec.configure do |config|
    config.before(:each) do |example|
      ActiveAdmin::Select2.inline_ajax_options = (example.metadata[:type] == :feature)
    end
  end

```

## Acknowledgements

Based on
[mfairburn/activeadmin-select2](https://github.com/mfairburn/activeadmin-select2).
