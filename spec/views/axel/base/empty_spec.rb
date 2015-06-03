require 'spec_helper'
require 'ap'
require 'pry-rails'

describe "axel/base/empty" do
  def self.view_checks
    it "renders the json envelope" do
      render template: "axel/base/empty", layout: "layouts/axel", formats: formats
      expect(rendered).to match /metadata/
      expect(rendered).to match /result/
    end
  end

  let(:formats) { [:json] }

  before do
    view.stub drop_meta?: false
    view.stub :safe_json_load do |arg|
      arg
    end
    view.stub errors: Axel::Payload::Errors.new {}
    view.stub metadata: Axel::Payload::Metadata.new {}
    view.stub :xml_clean do |arg|
      arg
    end
  end

  view_checks

  context "rendering xml" do
    let(:formats) { [:xml] }
    view_checks
  end
end
