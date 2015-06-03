module Axel
  module Associations
    class Base
      attr_accessor :model
      attr_accessor :relation_name
      attr_accessor :options

      def initialize(model, relation_name, options)
        self.model = model
        self.relation_name = relation_name.to_s
        self.options = options || {}
      end

      def handles_method?(method_name)
        matchers.any? { |matcher| method_name.to_s.match(matcher) }
      end

      def run_method(instance, method_name, *args, &block)
        if included?
          included_getter(instance, *args, &block)
        else
          method_chooser(method_name)[instance, *args, &block]
        end
      end

      private

      def included?
        !!options[:included]
      end

      def build_klass
        options[:class] || relation_name_klass
      end

      def premodule
        model.name.split("::")[0..-2].join("::")
      end

      def relation_name_klass
        "#{premodule}::#{relation_name.to_s.singularize.classify}".safe_constantize
      end

      def matcher_map
        {
          /\A#{relation_name}\z/ => :getter
        }
      end

      def matchers
        matcher_map.keys
      end

      def method_chooser(method_name)
        name = matcher_map[matchers.find { |matcher| method_name.to_s.match matcher }]
        if name
          method(name)
        else
          raise NoMethodError, "Could not find an association method for `#{method_name}'"
        end
      end
    end
  end
end
