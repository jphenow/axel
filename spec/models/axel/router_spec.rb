require 'spec_helper'
module Axel
  SomeClass = Class.new ServiceResource::Base
  SomeOtherClass = Class.new ServiceResource::Base

  describe Router do
    subject { Router.new(klass, path, method_name, options) }
    let(:path) { "users/:id/personas/:persona_id" }
    let(:klass) { SomeClass }
    let(:method_name) { :user_persona }
    let(:options) { {} }

    its(:parameters) { should == ["id", "persona_id"] }
    its(:arity) { should == 2 }

    before do
      klass.stub request_uri: "http://localhost", site: "http://localhost"
    end

    describe "with custom class filler" do
      describe "given class constant" do
        let(:options) { { class: SomeOtherClass } }
        let(:querier_stub) { double }
        it "calls via some other class" do
          SomeOtherClass.should_receive(:querier).and_return querier_stub
          querier_stub.should_receive(:without_default_path).and_return querier_stub
          querier_stub.should_receive(:at_path).and_return querier_stub
          querier_stub.should_receive(:request_options).and_return querier_stub
          subject.route 1
        end
      end

      describe "given class name" do
        let(:options) { { class_name: "axel/some_other_class" } }
        let(:querier_stub) { double }
        it "calls via some other class" do
          SomeOtherClass.should_receive(:querier).and_return querier_stub
          querier_stub.should_receive(:without_default_path).and_return querier_stub
          querier_stub.should_receive(:at_path).and_return querier_stub
          querier_stub.should_receive(:request_options).and_return querier_stub
          subject.route 1
        end
      end
    end

    context "no arity" do
      let(:path) { "users" }
      let(:route_with_options) { subject.route(params: { some_param: 1 }) }
      its(:arity) { should == 0 }
      it "can route with regular params and request options" do
        route_with_options.send(:extra_paths).should == ["users"]
        route_with_options.send(:retrieve_request_options).should == {
          "headers" => { "Content-Type"=>"application/json" },
          "params" => { "some_param"=>1 }
        }
      end
    end

    context "route" do
      let(:regular_routed) { subject.route(1,2) }
      let(:hash_routed) { subject.route(id: 1, persona_id: 2) }
      let(:regular_routed_with_request_options) { subject.route(1, 2, params: { some_param: 1 }) }
      let(:hash_routed_with_request_options) { subject.route({ id: 1, persona_id: 2 }, { params: { some_param: 1 } }) }
      it "can route with regular params" do
        regular_routed.send(:extra_paths).should == ["users/1/personas/2"]
        regular_routed.send(:retrieve_request_options).should == {
          "headers" => { "Content-Type"=>"application/json" }
        }
      end

      it "can route with hash params" do
        hash_routed.send(:extra_paths).should == ["users/1/personas/2"]
        hash_routed.send(:retrieve_request_options).should == {
          "headers" => { "Content-Type"=>"application/json" }
        }
      end

      it "can route with regular params and request options" do
        regular_routed_with_request_options.send(:extra_paths).should == ["users/1/personas/2"]
        regular_routed_with_request_options.send(:retrieve_request_options).should == {
          "headers" => { "Content-Type"=>"application/json" },
          "params" => { "some_param"=>1 }
        }
      end

      it "can route with hash params and request options" do
        hash_routed_with_request_options.send(:extra_paths).should == ["users/1/personas/2"]
        hash_routed_with_request_options.send(:retrieve_request_options).should == {
          "headers" => { "Content-Type"=>"application/json" },
          "params" => { "some_param"=>1 }
        }
      end

      context "with arity of 1" do
        let(:path) { "users/:id/personas" }
        let(:hash_routed) { subject.route({ id: 1}) }
        let(:hash_routed_with_request_options) { subject.route({ id: 1}, { params: { some_param: 1 } }) }
        it "can route with hash params" do
          hash_routed.send(:extra_paths).should == ["users/1/personas"]
          hash_routed.send(:retrieve_request_options).should == {
            "headers" => { "Content-Type"=>"application/json" }
          }
        end

        it "can route with hash params and request options" do
          hash_routed_with_request_options.send(:extra_paths).should == ["users/1/personas"]
          hash_routed_with_request_options.send(:retrieve_request_options).should == {
            "headers" => { "Content-Type"=>"application/json" },
            "params" => { "some_param"=>1 }
          }
        end
      end
    end
  end
end
