# Mongod

Simple object-relational mapping gem for Mongo DB with Rails 4.
Pagination with Bootstrap enabled.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongod'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongod

## Usage

Please use this module as base class for your model.
Mongo DB has no schema, you know, you must implement validation and 

### Install

```ruby
require 'monogod'

class YourClass < Mongod::Client

  .
  .
  .

end
```

### Paginate

#### app/view/shared/_mongod_paginate.html.erb

Sample html.erb file included. please see https://github.com/taiyuf/ruby-mongod/tree/master/app/view/shared/_mongod_paginate.html.erb .


```ruby
<% unless obj.nil? %>
  <div class='center'>
    <nav>
        <%= ["<ul class='pagination'>",
             "<li#{previous_page_class(obj)}>",
             "<a href='#{previous_page_link(obj, url, params)}' aria-label='Previous'>",
             "<span aria-hidden='true'>&laquo;</span>",
             "</a>",
             "</li>"].join().html_safe %>

        <%= paginate_link(obj, url, params) %>

        <%= ["<li#{next_page_class(obj)}>",
             "<a href='#{next_page_link(obj, url, params)}' aria-label='Next'>",
             "<span aria-hidden='true'>&raquo;</span>",
             "</a>",
             "</li>",
             "</ul>"].join().html_safe %>
    </nav>
  </div>
<% end %>
```

#### app/helpers/mongod_paginate_helper.rb

Sample helper file included. please see https://github.com/taiyuf/ruby-mongod/tree/master/app/helpers/mongod_paginate_helper.rb .

and you may add some code at app/helpers/mongod_paginate_helper.rb.

```ruby
require 'mongod_paginate_helper'
include MongodPaginateHelper
```

#### on your view

Sample patial code.

```ruby
<%= render partial: 'shared/mongod_paginate',
locals: { obj:    @sample,
          url:    your_path,
          params: { foo: 'bar' } } %>

<% @sample.each do |s| %>

 .
 .
 .

```



## Contributing

1. Fork it ( https://github.com/taiyuf/mongod/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
