require 'spec_helper'
require 'json'
FakeResource = Class.new Axel::ServiceResource::Base
module Axel
  module ServiceResource
    describe Base do
      context "class" do
        subject { Base }

        context "#load_values" do
          let(:old_attributes) { { key_1: 'value_1', key_2: 'value_2' }.with_indifferent_access }
          let(:response_body) { '{"result":{"key_1":"value_1_mod"}}' }
          let(:new_attributes) { ::JSON.parse(response_body)['result'] }
          let(:object) { FakeResource.new(old_attributes) }
          let(:response) { double(body: response_body, success?: true, code: 200) }

          it 'merges attributes' do
            subject.load_values(object, response)
            object.attributes.should eq(old_attributes.merge(new_attributes))
          end
        end

        context "routes" do
          its(:routes) { should be_a HashWithIndifferentAccess }
          context "defining route" do
            after { subject.instance_variable_set("@_routes", nil) }
            it "sets up a route" do
              subject.should_not respond_to :user_with_id
              subject.route "user/:id", :user_with_id
              subject.should respond_to :user_with_id
            end
          end
        end

        context "site" do
          context "without setting site" do
            before { subject.stub(resource: double(base_url: "http://some-url")) }

            its(:site) { should == "http://some-url" }
          end

          context "manual set site" do
            before { subject.site("http://some-other-url") }
            after { subject.instance_variable_set("@site", nil) }
            it "set the site" do
              subject.site.should == "http://some-other-url"
            end
          end
        end

        context "path" do
          context "without setting path" do
            context "without resource" do
              its(:path) { should == "bases" }
            end

            context "with resource" do
              before { subject.stub(resource: double(path: "resources")) }

              its(:path) { should == "resources" }
            end
          end

          context "manual set path" do
            context "with resource" do
              before { subject.stub(resource: double(path: "resources")) }

              it "sets resource path" do
                subject.resource.should_receive(:path=).once
                subject.path "some_path"
              end
            end
          end

          context "without resource" do
            before { subject.stub resource: nil }
            after { subject.instance_variable_set("@path", nil) }
            it "sets instance variable" do
              subject.path "some_other_path"
              subject.instance_variable_get("@path").should == "some_other_path"
            end
          end
        end

        context "querier" do
          its(:querier) { should be_a Axel::Querier }
          it "has a querier where self is the klass" do
            subject.querier.klass.should == Base
          end
        end

        context "resource_name" do
          # testing order messes with the name
          before { subject.instance_variable_set("@_resource_name", nil) }
          after { subject.instance_variable_set("@_resource_name", nil) }
          it "sets the resource name and makes accessible" do
            subject.resource_name.should == "bases"
            subject.resource_name "users"
            subject.resource_name.should == "users"
          end
        end

        context "resource" do
          # testing order messes with the name
          before { subject.instance_variable_set("@_resource_name", nil) }
          after { subject.instance_variable_set("@_resource_name", nil) }
          # for the should_receive
          before { Axel.stub(resources: double) }
          it "tries based on the class name" do
            Axel.resources.should_receive(:[]).with "bases"
            subject.resource
          end

          it "with a resource name set it tries that name" do
            subject.resource_name "users"
            Axel.resources.should_receive(:[]).with "users"
            subject.resource
            subject.send(:instance_variable_set, "@_resource_name", nil)
          end
        end

        describe "uri_join" do
          it "builds a id path" do
            subject.uri_join("http://localhost", 1).should == "http://localhost/1"
          end

          it "builds a id path with extra" do
            subject.uri_join("http://localhost", "1/", "/personas/").should == "http://localhost/1/personas"
          end

          it "just one" do
            subject.uri_join("http://localhost").should == "http://localhost"
          end
        end

        context "#request" do
          let(:request_builder) { double }

          before do
            subject.should_receive(:build_request).with("http://localhost", { 'headers' => { 'Content-Type' => 'application/json'} }).and_return request_builder
            request_builder.should_receive(:run).once
          end

          it "builds and runs synchronous request with typhoid" do
            subject.request "http://localhost"
          end
        end

        context "#inherited" do
          subject { FakeResource }
          context "it setup accessors" do
            context "instance" do
              subject { FakeResource.new }
              it { should respond_to :id }
              it { should respond_to :id= }
              it { should respond_to :uri }
              it { should respond_to :uri= }
            end
          end
        end
      end

      context "instance" do
        subject { Base.new params }
        let(:params) { {} }

        context "resource_exception" do
          context "remote errors" do
            let(:remote_errors) { Payload::Errors.new status: 404, messages: ["Fail!"] }
            before do
              subject.stub remote_errors: remote_errors
            end

            it "sets error resource exception" do
              subject.resource_exception.to_s.should == "Failed. HTTP Status: 404, Messages: Fail!"
            end
          end
        end

        context "new instance" do
          context "without envelope response" do
            let(:params) { { id: 1 } }

            its(:envelope?) { should be_falsey }

            its(:metadata) { should be_a Payload::Metadata }
            it "sets no metadata" do
              subject.metadata.attributes.should == {}
            end

            its(:remote_errors) { should be_a Payload::Errors }
            it "sets error" do
              subject.remote_errors.status_code.should == 200
              subject.remote_errors.messages.should == []
            end

            its(:result) { should == { id: 1 }.with_indifferent_access }
            it "converts attributes to result" do
              subject.result.should == subject.attributes
            end
          end

          context "with envelope response" do
            let(:params) { { metadata: { current_user: { id: 1 } }, result: { id: 1 } } }

            its(:envelope?) { should be_truthy }

            its(:metadata) { should be_a Payload::Metadata }
            it "sets metadata" do
              subject.metadata[:current_user].should == { id: 1 }.with_indifferent_access
            end

            its(:remote_errors) { should be_a Payload::Errors }
            it "sets error" do
              subject.remote_errors.status_code.should == 200
              subject.remote_errors.messages.should == []
            end

            its(:result) { should == { id: 1 }.with_indifferent_access }
            it "converts attributes to result" do
              subject.result.should == subject.attributes
            end
          end
        end

        context "request_uri" do
          context "uri set by incoming object" do
            let(:params) { { metadata: { current_user: { id: 1 } }, result: { id: 1, uri: "http://localhost/users" } } }

            its(:request_uri) { should == "http://localhost/users" }
          end

          context "uri computed" do
            before do
              Base.stub site: "http://localhost", path: "users"
            end

            its(:request_uri) { should == "http://localhost/users" }
          end
        end
      end
    end
  end
end
