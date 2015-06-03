module Axel
  class Inspector
    private
    attr_writer :object
    attr_writer :parens_params
    attr_writer :attributes

    public
    attr_reader :object
    attr_reader :parens_params
    attr_reader :attributes

    def initialize(object, parens_params = [], attributes = [])
      self.object = object
      self.parens_params = hasherize parens_params
      self.attributes = hasherize attributes
    end

    def inspect
      class_name.tap do |string|
        string << "(#{display_parens})" unless parens_params.empty?
        string << " #{display_attributes}" unless attributes.empty?
        unless class?
          string.prepend "#<"
          string << ">"
        end
      end
    end

    def class_name
      class? ? object.name : object.class.name
    end
    private :class_name

    def class?
      object.is_a?(Class)
    end

    def display_parens
      display parens_params
    end
    private :display_parens

    def display_attributes
      display attributes, :show_keys
    end
    private :display_attributes

    def display(array, show_keys = false)
      array.collect { |key,value|
        show_keys ? "#{key}: #{attribute_for_inspect(value)}" : attribute_for_inspect(value)
      }.join(", ")
    end
    private :display

    def attribute_for_inspect(value)
      if value.is_a?(String) && value.length > 50
        "#{value[0..50]}...".inspect
      elsif value.is_a?(Date) || value.is_a?(Time)
        %("#{value}")
      else
        value.inspect
      end
    end
    private :attribute_for_inspect

    def safe_send(key)
      object.public_send(key)
    rescue
      nil
    end
    private :safe_send

    def hasherize(params)
      if params.is_a? Hash
        params
      elsif params.is_a? Array
        Hash[params.map { |key|
          begin
            [key, safe_send(key)] if object.respond_to? key
          rescue
            [key, "<Error Collecting>"]
          end
        }.compact]
      else
        {}
      end
    end
    private :hasherize
  end
end
