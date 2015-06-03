module Axel
  module Payload
    class RemoteError < StandardError
      attr_reader :remote_errors
      def initialize(remote_errors)
        @remote_errors = remote_errors
      end

      def to_s
        "Failed. HTTP Status: #{remote_errors.status_code}, Messages: #{@remote_errors.messages.join('. ')}"
      end
    end
  end
end
