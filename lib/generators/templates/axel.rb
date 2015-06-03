Axel.config do |config|
  # The API Proxy's `/registry` endpoint holds information about
  # what resources connect to what services and where. We can leverage
  # that endpoint to automatically configure objects for data retrieval
  # and creation. To start, you'll want to configure the API Proxy location for
  # automatically retrieving resource location configs:
  #
  #   config.set_proxy_url "http://api.your-platform.com"
  #
  # Services may be added manually:
  #
  #   config.add_service "github", "http://api.github.com/v3/"
  #
  # Service locations can be forced to a specific URL:
  #
  #   config.service_configs[:user_service].url = "http://localhost:1337"
  #
  # Because of the API Proxy, many resources should be available automatically.
  # You can then start setting what attributes you want easier access
  # to for certain resources:
  #
  #   config.resources[:users].attributes << :user_name
  #   config.resources[:personas].attributes = [:first_name, :last_name]
  #
  # While many resources are automatically created, you can also manually add
  # resources:
  #
  #   config.add_resource "github", "repos" # `, service: { url: ".." } needed if the service was not added previously
  #
  # Resources can set their paths manually:
  #
  #   config.resources[:personas].path = "people"
  #
  # The Api proxy config and configs for altering resources/services will make
  # it so when you inherit from Axel::ServiceResource::Base you get some
  # free configuration. Example:
  #
  #   module MyApp
  #     class User
  #       resource # => <#Axel::Configurations::Resource users service: #<Axel::Configurations::Service user-service>>
  #       path     # => "/users"
  #       site     # => "https://user-service.your-platform.com"
  #     end
  #   end
  #
  # To configure URI conversion to certain environment URIs. Strategies
  # are either suffix strings or Procs that accept a base-name (usually app name)
  # and a number (for staging numbers). Define strategies here like so:
  #
  #   config.environment_uri_config = {
  #     dev: {
  #       host: ".dev",
  #       scheme: "http"
  #     },
  #     stage: {
  #       host: ->(base, n) { "#{base}.stage#{n}.ngin-staging.com" },
  #       scheme: "https"
  #     },
  #     prod: {
  #       host: ".your-platform.com",
  #       scheme: "https"
  #     }
  #   }
  #
  # This now means you can do:
  #
  #   Axel::Uri.new("http://user-service.dev/users").to(:prod).to_s
  #   # => "http://user-service.your-platform.com/users"
  #
  # With that set you can quickly convert all URLs in objects that use axel
  # for resource location to another environment:
  #
  #   config.set_environment :stage, 2
  #
  # Do you use rails-api instead of Rails proper? Set:
  #
  #   config.uses_rails_api = true  # Default: false
  #
  # This ensures that you use the ActionController::API rather than Rails' default
  # ActionController::Base
end
