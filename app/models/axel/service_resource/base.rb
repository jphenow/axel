module Axel
  module ServiceResource
    class Base < Typhoid::Resource
      extend Axel::CascadableAttribute
      include Inspects
      include Queries
      include Routes
      include AutomaticResource
      include TyphoidExtensions
      include Requesters
      include Associations
      include Attributes

      # Standard fields that should be on almost all objects
      # coming in
      field :id
      field :uri

      delegate :paged?,
        :total_pages,
        to: :metadata

      def initialize(params = {})
        super (params || {}).with_indifferent_access
      end

      # Grab the classlevel block that defines parameters to pass with
      # a reload and evaluate that within this instance
      def reload_params
        {}
      end
      private :reload_params

      def reload
        reset_association_cache!
        request_and_load do
          self.class.manual_request :get, reload_uri, reload_params
        end
      end

      def reload_uri
        request_uri
      end
      private :reload_uri
    end
  end
end
