module Axel
  module Payload
    class Errors < Base
      root_node :error
      attribute :messages, default: []
      attribute :status, default: 200, read: :private
      SUCCESS_CODES = [200, 201, 202, 204]

      def initialize(params = {})
        super
        @suppress_response_codes = !!@attributes[:suppress_response_codes]
      end

      def exception
        RemoteError.new(self) unless success?
      end

      def success?
        SUCCESS_CODES.include?(status_code.to_i) && messages.empty?
      end

      def messages=(messages)
        @attributes[:messages] = [messages].flatten.compact
      end

      def status=(status)
        @attributes[:status] = status
      end

      def header_status
        suppress_response_codes? ? 200 : status_code
      end

      def <<(message)
        @attributes[:messages] << message
      end

      def display
        drop? ? {} : { status: status_code, messages: messages }
      end

      def display?
        !SUCCESS_CODES.include?(status_code.to_i) || messages.present?
      end

      def new_error(status, *messages)
        self.status = status if status
        self.messages = self.messages + messages
      end

      def status_code
        status ? Rack::Utils.status_code(status) : 200
      end

      private

      def suppress_response_codes?
        @suppress_response_codes
      end
    end
  end
end
