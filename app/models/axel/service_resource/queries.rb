Axel::Querier # Autoloading
module Axel
  module ServiceResource
    module Queries
      extend ActiveSupport::Concern

      included do
        # Use Query methods from a Querier instance
        class << self
          delegate *Axel::Querier.query_methods, to: :querier
        end
      end

      module ClassMethods
        # Entry point to querying methods like:
        #   #where
        #   #path
        #   #uri
        def querier
          Axel::Querier.new self
        end
      end
    end
  end
end
