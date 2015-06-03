module Axel
  module ServiceResource
    class Builder < Typhoid::Builder
      def result
        enveloped? ? parsed_body["result"] : parsed_body
      end

      def enveloped?
        parsed_body.respond_to?("has_key?") && parsed_body.has_key?("metadata") && parsed_body.has_key?("result")
      end

      def array?
        result.is_a?(Array)
      end

      def singular?
        !array?
      end

      def metadata
        parsed_body["metadata"] if enveloped?
      end

      def errors
        parsed_body["errors"] if enveloped?
      end

      def compiled_payloads
        Array(result).map { |res| { "metadata" => metadata, "errors" => errors, "result" => res } }
      end

      def build_array
        compiled_payloads.collect { |single|
          build_from_klass(single)
        }
      end
      private :build_array
    end
  end
end
