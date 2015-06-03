module Axel
  module ServiceResource
    module Associations
      def self.included(base)
        base.extend(ClassMethods)
      end

      def method_missing(method_name, *args, &block)
        if self.class.associations_respond_to?(method_name)
          cache_association method_name do
            self.class.association(method_name).run_method(self, method_name, *args, &block)
          end
        else
          super
        end
      end

      def respond_to?(method_name, include_private = false)
        self.class.associations_respond_to?(method_name) || super
      end

      def reset_association_cache!
        @association_cache = {}
      end

      def association_cache
        @assocation_cache ||= {}
      end
      private :association_cache

      def cache_association(name, &block)
        association_cache[name] ||= block.call
      end
      private :cache_association

      module ClassMethods
        def belongs_to(relation_name, options = {})
           belongs_to_associations[relation_name] =
             Axel::Associations::BelongsTo.new(self, relation_name, options)
        end

        def has_many(relation_name, options = {})
           has_many_associations[relation_name] =
             Axel::Associations::HasMany.new(self, relation_name, options)
        end

        def has_one(relation_name, options = {})
           has_one_associations[relation_name] =
             Axel::Associations::HasOne.new(self, relation_name, options)
        end

        def associations_respond_to?(method_name)
          !!association(method_name)
        end

        def association(method_name)
          associations.values.find { |association| association.handles_method? method_name }
        end

        private

        def associations
          belongs_to_associations.merge(has_many_associations).merge(has_one_associations)
        end

        def has_one_associations
          @__has_one_associations ||= {}.with_indifferent_access
        end

        def belongs_to_associations
          @__belongs_to_associations ||= {}.with_indifferent_access
        end

        def has_many_associations
          @__has_many_associations ||= {}.with_indifferent_access
        end
      end
    end
  end
end
