require 'spec_helper'
SomeClass = Class.new do
  def self.routes
    {}
  end

  def self.retrieve_default_request_options(options)
    Axel::RequestOptions.new({}, options).compiled
  end
end

module Axel
  describe Querier do
    subject { Querier.new klass }
    let(:klass) { SomeClass.tap { |c| c.stub request_uri: "http://localhost" } }

    its(:klass) { should == klass }

    before do
      SomeClass.stub :request do
        [SomeClass.new]
      end
    end

    describe "paged" do
      describe "paged, but not asked for" do
        let(:returned) { [double(paged?: true)] }
        it "should be requested once" do
          klass.should_receive(:request).once.and_return(returned)
          subject.to_a.should == returned
        end
      end

      describe "paged requested" do
        describe "nil element" do
          it "returns empty array" do
            klass.should_receive(:request).once.and_return([])
            subject.paged.to_a.should == []
          end
        end

        describe "single element" do
          let(:returned) { [double(paged?: false)] }

          it "returns singular array" do
            klass.should_receive(:request).once.and_return(returned)
            subject.paged.to_a.should == returned
          end
        end

        describe "multiple pages" do
          let(:returned) { [double(paged?: true, total_pages: 3)] }

          it "returns singular array" do
            klass.should_receive(:request).exactly(3).times.and_return(returned)
            subject.paged.to_a.should == returned + returned + returned
          end
        end
      end
    end

    describe "accidentally build an array" do
      before do
        subject.stub build_into_response_container: []
      end

      it "successfully builds from a list" do
        subject.send :run_requests # should not error, want full trace if it DOES error
      end
    end

    describe "to_a" do
      it "calls run_requests" do
        subject.should_receive(:run_requests).once.and_return []
        subject.to_a
      end
    end

    describe "path" do
      subject { Querier.new(klass).at_path("some_resource", "1") }
      before do
        subject.class.any_instance.stub manual_uri: "http://localhost"
      end

      it "has a built request_uri" do
        subject.send(:request_uri).should == "http://localhost/some_resource/1"
      end

      it "has appended the request_uri" do
        subject.at_path("another_resource")
          .send(:request_uri).should == "http://localhost/some_resource/1/another_resource"
      end
    end

    describe "where" do
      subject { Querier.new(klass).where(id: 1) }
      it "sets parameters" do
        subject.send(:retrieve_request_options).should == {"headers"=>{"Content-Type"=>"application/json"}, "params"=>{"id"=>1}}
      end

      it "has appended the request_uri" do
        subject.where(name: "jon").send(:retrieve_request_options).should == {"headers"=>{"Content-Type"=>"application/json"}, "params"=>{"id"=>1, "name"=>"jon"}}
      end
    end

    describe "uri" do
      subject { Querier.new(klass).uri("http://user-service.dev") }

      it "has a built request_uri" do
        subject.send(:manual_uri).should == "http://user-service.dev"
        subject.send(:request_uri).should == "http://user-service.dev"
      end

      it "has appended the request_uri" do
        subject.uri("http://other-url").send(:manual_uri).should == "http://other-url"
        subject.uri("http://other-url").send(:request_uri).should == "http://other-url"
      end
    end

    describe "none" do
      it "forces empty" do
        subject.none == []
      end
    end

    describe "reload" do
      before do
        subject.send :loaded=, true
        subject.send :records=, [1,2,3]
      end

      it "resets variables and tries to force a reload of data" do
        subject.loaded?.should be_truthy
        subject.send(:records).should == [1,2,3]
        subject.reload
        subject.loaded?.should be_falsey
        subject.send(:records).should == []
      end
    end

    describe "enumerations" do
      it { should respond_to :each }
      it { should respond_to :first }
      it { should respond_to :last }

      its(:each) { should be_an Enumerator }
    end

    describe "loaded?" do
      its(:loaded?) { should == false }
      describe 'with ran requests' do
        it "becomes loaded when to_a ran" do
          expect { subject.to_a }.to change { subject.loaded? }.from(false).to(true)
        end
      end
    end
  end
end
