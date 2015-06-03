module Axel
  module ApplicationHelper
    def page_title
      result = controller_params_to_locale
      result ? " - #{result}" : ""
    end

    private

    def controller_params_to_locale
      sections = params[:controller].to_s.split("/").compact.map(&:to_sym)
      action = params[:action].to_s.to_sym
      title = t(:titles)

      sections.each do |s|
        title = title.send("[]", s) if title.is_a?(Hash)
      end
      if title.is_a? Hash
        title[action]
      elsif title.is_a?(String) && !title.match(/class=\"translation_missing\"/)
        title
      else
        nil
      end
    end
  end
end
