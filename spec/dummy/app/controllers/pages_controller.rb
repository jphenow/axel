class PagesController < ApplicationController
  respond_to_json_xml
  def show
    respond_to_empty
  end
end
