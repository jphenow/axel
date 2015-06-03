module Axel
  module Associations
    class BelongsTo < Base

      private

      def included_getter(instance, *args, &block)
        relation_attributes = (instance.try(:attributes) || {})[relation_name]
        build_klass.new(relation_attributes) if relation_attributes
      end

      def find_nested?
        !!options[:find_nested]
      end

      def getter(instance, *args, &block)
        request_options = args.extract_options!
        if find_nested?
          build_klass
            .querier
            .without_default_path
            .at_path(route_path(instance))
            .request_options(request_options)
            .first
        else
          build_klass.find(instance.public_send(association_id_method), request_options)
        end
      end

      def route_path(instance)
        [URI(instance.request_uri).path, association_path(instance)].join("/")
      end

      def association_path(instance) # needs to be belongs_to, some looks has_many
        "#{relation_name.to_s.pluralize}/#{instance.public_send(association_id_method)}"
      end

      def association_id_method
        options[:id_attribute] || "#{relation_name.to_s.singularize.underscore}_id"
      end
    end
  end
end
