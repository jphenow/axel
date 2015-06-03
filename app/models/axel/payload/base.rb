module Axel
  module Payload
    class Base
      attr_reader :attributes

      delegate :fetch, to: :attributes

      def self.root_node(name = nil)
        @root_node = name if name
        @root_node
      end

      def self.attribute(name, options = {})
        attribute_defaults[name.to_s.to_sym] = options[:default]
        visibility_read = options.has_key?(:read) ? options[:read] : true
        visibility_write = options.has_key?(:write) ? options[:write] : true
        if visibility_read
          define_method name do
            @attributes[name]
          end
          if %w[public private protected].include? visibility_read.to_s
            send visibility_read, name
          end
        end

        if visibility_write
          define_method "#{name}=" do |new_value|
            @attributes[name] = new_value
          end
          if %w[public private protected].include? visibility_write.to_s
            send visibility_write, name
          end
        end
      end

      def self.attribute_defaults
        @attribute_defaults ||= {}
      end

      def reset!
        @attributes = {}
        apply_defaults
        self
      end

      def initialize(params = {})
        apply_defaults
        params = params.is_a?(Hash) ? params : {}
        @attributes.merge! params
      end

      def []=(key, value)
        @attributes[key] = decode(value)
      end

      def [](key)
        @attributes[key]
      end

      def display
        drop? ? {} : @attributes
      end

      def display?
        true
      end

      def drop?
        !!@drop
      end

      def drop!
        @drop = true
      end

      def to_json
        display? ? display.to_json : ""
      end

      def to_xml
        display? ? display.to_xml(dasherize: false, skip_instruct: true, root: self.class.root_node) : ""
      end

      def apply_defaults
        @attributes = self.class.attribute_defaults.with_indifferent_access
      end
      private :apply_defaults

      def decode(input)
        if input.is_a? String
          begin
            ActiveSupport::JSON.decode input
          rescue MultiJson::DecodeError, JSON::ParserError
            begin
              Hash.from_xml input
            rescue REXML::ParseException
              input
            end
          end
        else
          input
        end
      end
      private :decode
    end
  end
end
