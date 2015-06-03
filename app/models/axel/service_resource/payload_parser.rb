module Axel
  module ServiceResource
    class PayloadParser
      def initialize(payload)
        self.payload = ActiveSupport::HashWithIndifferentAccess.new payload
      end

      def parsed
        [payload, result, metadata, remote_errors]
      end

      private
      attr_accessor :payload

      def metadata
        Payload::Metadata.new bare_metadata
      end

      def remote_errors
        Payload::Errors.new bare_remote_errors
      end

      def result
        (payload[:result] || backup_result ).with_indifferent_access
      end

      def bare_metadata
        (payload[:metadata] || {} ).with_indifferent_access
      end

      def bare_remote_errors
        raw = payload[:errors] || payload[:error] || {}
        raw = { messages: raw } if raw.is_a?(Array)
        raw.with_indifferent_access
      end

      def payload_is_enveloped?
        payload.is_a?(Hash) && payload.has_key?(:metadata) && payload.has_key?(:result)
      end

      def backup_result
        payload_is_enveloped? ? {} : payload
      end
    end
  end
end
