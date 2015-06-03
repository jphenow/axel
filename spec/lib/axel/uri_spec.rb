require 'spec_helper'
module Axel
  describe "Uri" do
    subject { Uri.new base_url }
    let(:base_url) { "http://user-service.stage.com/users" }

    before do
      subject.stub config: {
        dev: {
          host: ".dev",
          scheme: "http"
        },
        stage: {
          host: ->(base, n) { "#{base}.stage#{n}.com" },
          scheme: "https"
        },
        prod: {
          host: ".your-platform.com",
          scheme: "https"
        }
      }
    end
    it "to dev switches out the stage URI for .dev" do
      subject.to(:dev).to_s.should == "http://user-service.dev/users"
    end

    it "for stage" do
      subject.to(:stage).to_s.should == "https://user-service.stage.com/users"
    end

    it "for stage n" do
      subject.to(:stage, 2).to_s.should == "https://user-service.stage2.com/users"
    end

    it "for prod" do
      subject.to(:prod).to_s.should == "https://user-service.your-platform.com/users"
    end

    its(:dashed_app_name) { should == "user-service" }
    its(:app_name) { should == "User Service" }
  end
end
