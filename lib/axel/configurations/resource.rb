module Axel
  module Configurations
    class Resource
      attr_reader :name
      attr_reader :service
      attr_accessor :attributes
      attr_writer :path

      def initialize(name, service, options = {})
        @name = name.to_s.singularize
        @service = service
        @attributes = options[:attributes] || []
        @path = options[:path] # If nil it will try to build URL from name and service
      end

      def full_url
        URI.join(base_url, path).to_s
      end

      def base_url
        service.url
      end

      def path
        @path || name.pluralize
      end
    end
  end
end
