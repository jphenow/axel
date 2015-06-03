require 'axel/configurations/resource'
module Axel
  module Configurations
    class Service
      attr_reader :name
      attr_writer :url
      attr_reader :resources

      delegate :manual_environment_set?,
        :environment,
        to: Axel

      def initialize(name, url)
        @name = name.to_s.singularize
        @resources = {}.with_indifferent_access
        @url = url.to_s
      end

      def url
        manual_environment_set? ? Uri.new(@url).to(*environment).to_s : @url
      end

      def add_resource(resource_name, options = {})
        resources[resource_name] = Configurations::Resource.new(resource_name, self, options)
      end
    end
  end
end
