Axel::Router
module Axel
  module ServiceResource
    module Routes
      extend ActiveSupport::Concern

      module ClassMethods
        def routes
          @_routes ||= {}.with_indifferent_access
        end

        def route(route_path, name, options = {})
          new_route = Router.new(self, route_path, name, options)
          routes[new_route.method_name] = new_route.define_route
        end
      end
    end
  end
end
