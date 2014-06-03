# ActiveAdmin Select2

## Description

Incorporate Select2 JQuery into your ActiveAdmin apps.

## Installation

Add `activeadmin`, `jquery-rails` and `select2-rails` to your Gemfile:

```ruby
   gem 'activeadmin'
   gem 'jquery-rails'
   gem 'select2-rails'
```

And add `activeadmin-select2` to your Gemfile:

```ruby
   gem 'activeadmin-select2', github: 'mfairburn/activeadmin-select2'
```

Add the activeadmin-select2 calls to the active_admin stylesheets and javascripts with:

```active_admin.css.scss
   @import "active_admin/select2/base";
```

```active_admin.js.coffee
   #= require active_admin/select2
```


## Usage

### Filters

Standard :select filters will automagically be converted to Select2 filters.  If you want a multi-select combo-box then use:

```ruby
   ActiveAdmin.register Products do

      filter :fruits, as: :select2_multiple, collection: [:apples, :bananas, :oranges]

   end
```

### Select Lists

To use a Select2 style list simply change from :select to :select2 or :select2_multiple

```ruby
   ActiveAdmin.register Products do

     form do |f|
       f.input :fruit, as: :select2
     end

     form do |f|
       f.inputs "Product" do
         f.has_many :fruits, allow_destroy: true, new_record: "Add Fruit" do |e|
           e.input :fruit, as: :select2_multiple
         end
       end
     end

   end
```

## Acknowledgements


## Copyright

Copyright (c) 2014 Mark Fairburn, Praxitar Ltd
See the file LICENSE.txt for details.
