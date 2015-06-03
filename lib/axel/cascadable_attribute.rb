module Axel
  module CascadableAttribute
    def inherited(klass)
      super
      _cascadable_attributes.each do |attribute_name|
        klass.instance_variable_set "@#{attribute_name}", _instance_var_for("@#{attribute_name}")
      end
    end

    def cascade_attribute(*attribute_names)
      self._cascadable_attributes += attribute_names.map(&:to_s)
    end

    def _cascadable_attributes
      @_cascadable_attributes ||= ["_cascadable_attributes"]
    end

    def _cascadable_attributes=(arry)
      @_cascadable_attributes = arry
    end

    def _instance_var_for(attribute_name)
      attribute = instance_variable_get(attribute_name)
      attribute.clone
    rescue
      begin
        attribute.dup
      rescue
        attribute
      end
    end
  end
end
