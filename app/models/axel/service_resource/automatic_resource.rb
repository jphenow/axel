module Axel
  module ServiceResource
    module AutomaticResource
      extend ActiveSupport::Concern

      module ClassMethods
        # Name the resource. Used if you call your class Foo but the API
        # Proxy know it as "Bar". This will resolve that configuration
        # disconnect
        def resource_name(name = nil)
          @_resource_name = name.to_s.underscore.pluralize if name
          @_resource_name || self.name.split("::").last.underscore.pluralize
        end

        # Resource object that holds configuration information about the service
        # and path
        def resource
          Axel.resources[resource_name]
        end
      end
    end
  end
end
