module Axel
  module Associations
    class HasMany < Base

      private

      def included_getter(instance, *args, &block)
        Array(instance.attributes[relation_name]).map { |attributes| build_klass.new(attributes) }
      end

      def getter(instance, *args, &block)
        request_options = args.extract_options!
        build_klass
          .querier
          .without_default_path
          .at_path(route_path(instance))
          .request_options request_options
      end

      def route_path(instance)
        [URI(instance.request_uri).path, association_path].join("/")
      end

      def association_path # needs to be belongs_to, some looks has_many
        options[:suffix_path].present? && options[:suffix_path] || relation_name.to_s
      end
    end
  end
end
