--------------------------------------

# Welcome to Axel

## Configuration

In your `app/controllers/application_controller.rb` change to:

```ruby
class ApplicationController < Axel::BaseController
  layout "axel" # For json and xml API output
  #.......
  #.......
end
```

Please see `config/initializers/axel.rb` to configure inter-service connection.

You'll also want to have a look at the README.md found at the project homepage:
http://github.com/tstmedia/axel.  There you'll find more information about what the
`Axel::BaseController` can do for your API controllers and how to operate inter-
service requests.
