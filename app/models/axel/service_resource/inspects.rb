module Axel
  module ServiceResource
    module Inspects
      extend ActiveSupport::Concern

      def inspect
        Inspector.new(self, [:request_uri], [:attributes, :metadata, :remote_errors]).inspect
      end

      module ClassMethods
        def inspect
          Inspector.new(self, [:request_uri]).inspect
        end
      end
    end
  end
end
