require 'spec_helper'

module Axel
  describe ApiProxy do
    context "the class" do
      subject { ApiProxy }

      its(:cache_file) { should be_a Pathname }
      its(:cache_dir) { should be_a Pathname }

      context "invalid json" do
        let(:json) { "not_json" }
        it "can't parse, toss back hash as we expect" do
          subject.build(nil, double(success?: true, body: json)).should == {}
        end
      end
    end

    context "the instance" do
      subject { ApiProxy.new endpoint }
      let(:endpoint) { "http://api.not-existant" }

      context "get new data" do
        let(:new_data) { "{\"routes\":[{\"service\":\"https://user-service.stage.com\",\"path\":\"/personas\",\"matcher\":\"^/personas(\\\\/[\\\\w]+)*\\\\/?(\\\\.\\\\w+)?(\\\\?.*)?$\"},{\"service\":\"https://cms-service.stage.com\",\"path\":\"/mobile_products\",\"matcher\":\"^/mobile_products(\\\\/[\\\\w]+)*\\\\/?(\\\\.\\\\w+)?(\\\\?.*)?$\"}]}" }

        before do
          loaded = MultiJson.load new_data
          subject.class.stub request: loaded
          subject.stub write_cache: loaded["routes"]
        end

        it "configs the resources" do
          Axel.send(:_config).should_receive(:add_resource).with(
            "user_service",
            "personas",
            service: { url: "https://user-service.stage.com" }).once
          Axel.send(:_config).should_receive(:add_resource).with(
            "cms_service",
            "mobile_products",
            service: { url: "https://cms-service.stage.com" }).once
          subject.register!
        end
      end

      context "get old data" do
        let(:cached_data) { [{"service"=>"https://user-service.stage.com", "path"=>"/personas", "matcher"=>"^/personas(\\/[\\w]+)*\\/?(\\.\\w+)?(\\?.*)?$"}, {"service"=>"https://cms-service.stage.com", "path"=>"/mobile_products", "matcher"=>"^/mobile_products(\\/[\\w]+)*\\/?(\\.\\w+)?(\\?.*)?$"}] }

        before do
          subject.stub read_cache: cached_data
        end

        it "configs the resources" do
          Axel.send(:_config).should_receive(:add_resource).with(
            "user_service",
            "personas",
            service: { url: "https://user-service.stage.com" }).once
          Axel.send(:_config).should_receive(:add_resource).with(
            "cms_service",
            "mobile_products",
            service: { url: "https://cms-service.stage.com" }).once
          subject.register!
        end
      end
    end
  end
end
