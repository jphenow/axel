require 'spec_helper'
module Axel
  describe Inspector do
    subject { Inspector.new object, parens, attributes }
    let(:object) { double(id: 1, name: "Jon", request_uri: "http://some-url/users/1") }
    let(:parens) { [:request_uri] }
    let(:attributes) { { id: 1, name: "Jon" } }

    its(:object) { should == object }
    it "retrieves parens_params keys" do
      subject.parens_params.keys.should == parens
    end
    its(:attributes) { should == attributes }

    describe "with parens and attributes set" do
      its(:inspect) { should == "#<RSpec::Mocks::Double(\"http://some-url/users/1\") id: 1, name: \"Jon\">" }
    end

    describe "with an erroring parens attribute" do
      before { object.stub(:request_uri) { raise "No good" } }
      its(:inspect) { should == "#<RSpec::Mocks::Double(nil) id: 1, name: \"Jon\">" }
    end

    describe "without parens" do
      let(:parens) { nil }
      its(:inspect) { should == "#<RSpec::Mocks::Double id: 1, name: \"Jon\">" }
    end

    describe "without attributes" do
      let(:attributes) { nil }
      its(:inspect) { should == "#<RSpec::Mocks::Double(\"http://some-url/users/1\")>" }
    end

    describe "with a class" do
      before do
        subject.stub class?: true
      end

      let(:object) { double request_uri: "http://example_uri/users", name: "MyClass" }
      let(:parens) { [:request_uri] }
      let(:attributes) { nil }
      its(:inspect) { should == "MyClass(\"http://example_uri/users\")" }
    end
  end
end
