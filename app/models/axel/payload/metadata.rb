module Axel
  module Payload
    class Metadata < Base
      root_node :metadata

      def paged?
        total_pages > 1
      end

      def total_pages
        raw = pagination_settings["total_pages"].to_i
        raw == 0 ? 1 : raw
      end

      def merge!(other_object)
        tap do
          @attributes.merge! mergeable_from(other_object)
        end
      end

      def merge(other_object)
        #self.class.new(attributes).tap do |c|
        dup.tap do |c|
          c.merge!(mergeable_from(other_object))
        end
      end

      def dup(*args)
        super.tap do |d|
          d.instance_variable_set "@attributes", @attributes.clone
        end
      end

      def clone(*args)
        super.tap do |c|
          c.instance_variable_set "@attributes", @attributes.clone
        end
      end

      def pagination_settings
        fetch("pagination", {})
      end
      private :pagination_settings

      def mergeable_from(object)
        if object.respond_to?(:attributes) && object.attributes.is_a?(Hash)
          object.attributes
        elsif object.is_a? Hash
          object
        else
          {} # unmergeable, should think about erroring
        end
      end
      private :mergeable_from
    end
  end
end
