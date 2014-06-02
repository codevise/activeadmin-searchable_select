# Active Admin Select2

## Description

Incorporate Select2 JQuery into your ActiveAdmin apps.

## Installation

Add `jquery-rails` to your Gemfile:

```ruby
   gem 'jquery-rails'
```


Add `select2-rails` to your Gemfile:

```ruby
   gem 'select2-rails'
```

Add `activeadmin-select2` to your Gemfile:

```ruby
   gem 'activeadmin-select2', github: 'mfairburn/activeadmin-select2'
```

Replace active_admin stylesheets and javascripts with:

```sass
   @import "active_admin/select2/base"
```

```coffee
   #= require active_admin/select2
```


## Custom inputs usage

### Select2

The infamous jquery combobox. To use add to your Gemfile:

```ruby
   gem 'chosen-rails', group: :assets
```

and then in your assets:

```coffee
   #= require chosen-jquery
```

```sass
   @import "chosen"
```

Usage:

```ruby
   ActiveAdmin.register Product do

     form do |f|
       f.input :material, as: :chosen, create_option: true
     end

   end
```

## Copyright

Copyright (c) 2014 Mark Fairburn, Praxitar Ltd
See the file LICENSE.txt for details.
