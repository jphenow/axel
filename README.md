# Axel
[![Build Status](https://magnum.travis-ci.com/sportngin/axel.svg?token=JKgYC4kfXqjpwsFoBpzq)](https://magnum.travis-ci.com/sportngin/axel)

The building blocks for building a Sport Ngin Back-end API service:

* add some error helpers (error object)
* standardized XML/JSON envelope (metadata/error/result objects)
* adding `suppress_response_codes` to params will force a 200 and will only show errors
  in the error object of the response body
* standard controller responders to ensure JSON is always prefered, XML is acceptable, and
  the response always has a correct body that handles all errors

## Installation

Add this line to your application's Gemfile:

```ruby
source 'https://D9W5miiTyaf8EzrkWdTy@gem.fury.io/me/' # BELOW THE `source rubygems`
gem 'axel'
```

Then execute:

```bash
$ bundle
```

In your `app/controllers/application_controller.rb` (or wherever your base class is that will
use these helpers) change to:

```ruby
class ApplicationController < ActionController::Base
  include Axel::ControllerHelpers
end
```

## Usage

### Controller Specific Helpers

#### Errors

Errors object is available (as `errors`) from any controller:

```ruby
errors.header_status         # suppress_response_codes param will set to 200 by default
errors << "Error message!"   # add error messages
errors.display               # { status: errors.status_code, messages: errors.messages }
errors.display?              # Display errors? (was there an error added or status changed?)
errors.messages
errors.messages = []
errors.status = :not_found
errors.status_code            # => 404
errors.status = 403
errors.status_code            # => 403
errors.new_error(status, *m)  # set status, add an error or list of errors (not in an array object)

# Can also set on the fly:
rescue_error status: :not_found, message: "Error!"
rescue_error status: :unproccessable_entity, messages: ["Error!", "Error2!"]
```

#### Metadata

Metadata object that will be placed on every outgoing response body. You can add to the object like
so:

```ruby
metadata[:current_user] = current_user

# the body will then set this on the outgoing body:
# => { "metadata": { "current_user": "..." }, "result": "...", "...": "..." }
```

#### Responders
At the top of each controller (for APIs) should be:

```ruby
respond_to_json_xml
```

This defines `respond_to :json, :xml`.

making these responders good to use for defaults:

```ruby
respond_with_action :show   # Good for the end of a create to show the created object
render_action :show
respond_to_empty            # Render empty `result`, fill in `metadata`, `error` if necessary
render_empty
```

#### Resource finder

`find_resource` will automatically find a resource:

```ruby
class PostsController < ApplicationController
  before_filter :find_resource
  def show
    respond_with
  end
end

curl http://localhost:3000/posts/1 # finds Post 1 and renders
curl http://localhost:3000/posts/1
# => {"metadata":{},"error":{"status":404,"messages":["Record not found"]},"result":null}

# can also customize the find_resource with `finder` and `value`
# were `finder` is column and `value` is the value of the column
```

#### Param helpers

```ruby
query_params    # Only params on the query string
post_params     # POST params
object_params   # Either params under the object name (ie. {"user":".."} or all POST params
object_name     # singularized controller name for finding object_params
```

#### General workflow helpers

Helpers:

```ruby
force_ssl!        # raises Errors::ForceSSL
drop_meta!        # we don't want the requester to get data like current_user, etc.
drop_meta?        # Did we call `drop_meta!`?
format            # The format passed from the request OR JSON
render_nil_format # This is for rendering nils in json or XML (XML is blank, JSON is "null")
safe_json_load    # If you've already manually rendered some to json this helper safely loads it to a hash for re-JSONing
```

Errors are rescued to make for easier API workflow and responding:

```ruby
Axel::Errors::ForceSSL                # Drop meta
                                            # Status: Forbidden
                                            # Message: SSL is required

ActiveRecord::RecordNotFound                # Status: 404
                                            # Message: Record not found

Axel::Errors::NotAuthorized           # Status: 401
                                            # Message: User not authorized

ActiveModel::MassAssignmentSecurity::Error  # Status: 422
                                            # Message: Unacceptable parameter being used
```

### Interservice Helpers

#### Some setup examples

```ruby
Axel.config do |config|
  config.add_resource :user_service,
    :group,
    service: { url: "https://user-service.your-platform.com" }

  # Custom Path (otherwise defaults to plural of the resource_name (:user => "/users"))
  # config.add_resource :user_service,
  #   :user,
  #   service: { url: "https://user-service.your-platform.com" },
  #   attributes: [:user_name, :first_name],
  #   path: "owner"
end

class Group < Axel::ServiceResource::Base
  # Let's say your class doesn't match the configured resource, you can:
  resource_name :group

  # Setup fields (gets accessors, all available in #attributes)
  field :name
  field :owner_id
  field :owner_type
  field :uri

  route "/groups/mine", :mine
  route "/user/:user_id/groups", :by_user_id

  # Attached to every Group request, you can define instance defaults as well
  def self.default_request_options
    { headers: { "Accepts" => "stuff!", Authorization: "Bearer #{some_access_token}" } }
  end
end

group = Group.new name: "test", owner_id: 1, owner_type: "Organization", uri: "blargh"
group.save

my_groups = Group.mine
user_groups = Group.by_user_id(1)
user_groups = Group.by_user_id(user_id: 1)

a_group = Group.find(1)
```

#### Related data!

```ruby
class User < Axel::ServiceResource::Base
  has_many :personas
  has_one :email_address, class: Email, included: true
end

class Email < Axel::ServiceResource::Base
  belongs_to :user, find_nested: true
end

class Persona < Axel::ServiceResource::Base
  belongs_to :user
end

u = User.find(1)
u.personas            # => API call to /users/1/personas puts data in an array of Persona objects
u.email_address       # => Uses `email_address` in the User data to put into Email objects
Persona.find(1).user  # => API call to /users/#{persona.user_id} fills User object
Email.find(1).user    # => API call to /personas/1/user fills User Object
```

#### Some Chainable Query methods
```ruby
Group.where(name: "test")
# => https://user-service.your-platform.com/groups?name=test

Group.all params: { name: "test" }, body: jsonified_stuffs, headers: {}, method: :post

Group.uri("https://user-service.dev/groups").where(name: "Jon").all(headers: {})
# => http://user-service.dev/groups?name=Jon

Group.uri("https://user-service.dev").at_path("/other_groups_path").where name: "test"
# => http://user-service.dev/other_groups_path?name=test

Group.where(name: "Jon").all(headers: {}).none
# => [] # Will always be empty array

Group.none.where(name: "Jon")
# => [] # can chain

Group.without_default_path.at_path("groupies")
# => https://user-service.your-platform.com/groupies

# Enumerable works!
Groups.where(name: "test").each { |g| puts e.attributes.inspect }
groups = Groups.where(name: "test").to_a

# drop cached JSON, then you can requery
groups.reload.where(owner_id: 1)
```

#### More General Usage
``` ruby
new_user.metadata                 # => { .. } # Metadata section of JSON output
new_user.metadata[:current_user]  # => { "id"=>1, "user_name"=>"admin", "first_name"=>"Happy", "last_name"=>"Gilmore", "uri"=>"http://user-service.dev/users/1"}
new_user.errors.status_code       # => 200
new_user.errors.messages          # => []
new_user.result                   # => { ... } # Main envelope JSON body
```
For more info on what the requester is and can do check out
[Axel::ServiceResource::Base][srb]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[srb]: http://github.com/sportngin/axel/tree/master/app/models/axel/service_resource/base.rb
