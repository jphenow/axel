module Axel
  module ServiceResource
    module Requesters
      extend ActiveSupport::Concern

      def default_request_options;end

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

        def retrieve_default_request_options(options)
          RequestOptions.new(default_request_options, options).compiled
        end

        # Make a simple request and get a response back. Will build the
        # response into this object
        #
        # For options see Typhoeus::Request
        # args can be read like this: *paths, options = {}
        def request(uri, *args)
          options = args.extract_options!
          build_request(uri_join(uri, *args), retrieve_default_request_options(options)).run
        end

        # Make a request, but use the default request_uri for this object
        def from_base(*args)
          request request_uri, *args
        end

        # Resource endpoint for this API
        #
        #   base_url/organizations/1
        def find(id, params = {})
          from_base id, params
        end
      end
    end
  end
end
