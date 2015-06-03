module Axel
  module ServiceResource
    UnknownAttributeError = Class.new(StandardError)
    module Attributes
      def assign_attributes(new_attributes)
        return unless new_attributes

        new_attributes.each do |k, v|
          if respond_to?("#{k}=")
            send("#{k}=", v)
          else
            raise(UnknownAttributeError, "unknown attribute: #{k}")
          end
        end
      end

      def update_attributes(attributes)
        assign_attributes(attributes)
        save
      end
    end
  end
end
