require 'axel/configurations/service'
module Axel
  module Configurators
    class Services
      attr_reader :services
      def initialize
        @services = {}.with_indifferent_access
      end

      def resources
        services.values.collect(&:resources).inject({}.with_indifferent_access) { |hash, pair| hash.merge pair }
      end

      def add_service(service_name, url)
        if services[service_name]
          services[service_name].url = url if url
          services[service_name]
        else
          services[service_name] = Configurations::Service.new(service_name, url)
        end
      end

      def add_resource(service_name, resource_name, options = {})
        service = add_service service_name, (options.delete(:service) || {})[:url]
        service.add_resource resource_name, options
      end
    end
  end
end
