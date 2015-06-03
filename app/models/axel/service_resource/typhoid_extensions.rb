module Axel
  module ServiceResource
    module TyphoidExtensions
      extend ActiveSupport::Concern

      included do
        extend Axel::CascadableAttribute
        cascade_attribute :site
        cascade_attribute :path
        cascade_attribute :auto_init_fields
        protected
        attr_writer :attributes
        attr_writer :metadata
        attr_writer :remote_errors
        attr_writer :result
        attr_writer :payload

        public
        attr_reader :metadata
        attr_reader :remote_errors
        attr_reader :result
        attr_reader :payload
      end

      def envelope?
        payload.has_key?(:metadata) && payload.has_key?(:result)
      end

      def default_request_options;end

      def request_and_load(&block)
        metadata.reset!
        remote_errors.reset!
        super
      end

      # Makes Typhoid::Resource#success check remote_errors
      def resource_exception
        remote_errors.exception || super
      end

      def create_request(method = :post)
        object_request method, to_params.to_json
      end

      def update_request(method = :put)
        object_request method, to_params.to_json
      end

      def delete_request(method = :delete)
        object_request method
      end

      def build_typhoid_request(options = {})
        self.class.build_typhoid_request request_uri, options
      end

      def object_request(method, body = nil)
        bare_options = { method: method }
        bare_options[:body] = body if body
        build_typhoid_request retrieve_default_request_options(bare_options)
      end

      def load_values(hash = {})
        self.payload, self.result, self.metadata, self.remote_errors = PayloadParser.new(hash).parsed
        merge_result
        self
      end

      def merge_result
        self.attributes.deep_merge! result
      end

      def after_build(response, error)
        super
        self.remote_errors.status = response.code
      end

      def attributes
        @attributes ||= {}.with_indifferent_access
      end

      def retrieve_default_request_options(options)
        RequestOptions.new(compiled_default_request_options, options).compiled
      end
      private :retrieve_default_request_options

      def compiled_default_request_options
        (self.class.default_request_options ||{}).merge(default_request_options || {})
      end
      private :compiled_default_request_options

      module ClassMethods
        def default_request_options;end

        def manual_request(method, uri, request_options = {})
          Typhoeus::Request.send method, uri, request_options
        end

        def builder
          ::Axel::ServiceResource::Builder
        end

        def retrieve_default_request_options(options)
          RequestOptions.new(default_request_options, options).compiled
        end

        def build_typhoid_request(request_uri = nil, options = {})
          uri = request_uri || self.request_uri
          Typhoid::RequestBuilder.new(self, uri, options)
        end

        # Manually register base URL, useful if the API Proxy is pointing at the
        # wrong location or doesn't know about the location
        def site(url = nil)
          @site = url if url
          resource ? (@site || resource.base_url) : @site
        end

        # Manually register a path, useful if the API Proxy is pointing at the
        # wrong location or doesn't know about the location
        def path(path = nil)
          if resource
            resource.path = path if path
            resource.path
          else
            @path = path if path
            @path || resource_name
          end
        end
      end
    end
  end
end
