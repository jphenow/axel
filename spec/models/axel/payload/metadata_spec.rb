require 'spec_helper'
module Axel
  module Payload
    describe Metadata do
      describe "class" do
        subject { Metadata }
        its(:root_node) { should == :metadata }
      end

      context "instance" do
        before do
          subject[:name] = "jon"
        end

        it "isn't paged" do
          subject.paged?.should be_falsey
        end

        it "has 1 page" do
          subject.total_pages.should == 1
        end

        describe "drops" do
          context "with a drop" do
            it "changes the boolean and drops the message" do
              subject.drop?.should be_falsey
              subject.drop!
              subject.drop?.should be_truthy
              subject.display.should == {}
            end
          end

          context "without a drop" do
            its(:display) { should == { "name" => "jon" } }
          end
        end

        context "dup" do
          specify { subject.attributes.should_not be(subject.dup.attributes) }
        end

        context "clone" do
          specify { subject.attributes.should_not be(subject.clone.attributes) }
        end

        context "merge" do
          let(:age_metadata) { Metadata.new age: 10 }
          let(:name_metadata) { Metadata.new name: "tom" }

          it "merges a different key" do
            merged = subject.merge(age_metadata)
            subject.should_not == merged
            subject.attributes.should_not == merged.attributes
            subject.attributes.should == { name: "jon" }.with_indifferent_access
          end

          it "merges a similar key" do
            merged = subject.merge(name_metadata)
            subject.attributes.should_not == merged.attributes
            subject.attributes.should == { name: "jon" }.with_indifferent_access
          end
        end

        context "paged" do
          before do
            subject[:pagination] = { total_pages: 2 }
          end

          it "isn't paged" do
            subject.paged?.should be_truthy
          end

          it "has 1 page" do
            subject.total_pages.should == 2
          end
        end

        context "decode" do
          let(:xml) do
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?><current_user><id type=\"integer\">1</id></current_user>"
          end

          let(:json) do
            "{\"current_user\":{\"id\":1}}"
          end

          let(:ruby_hash) do
            { current_user: { id: 1 } }
          end

          it "set the hash for json" do
            subject[:json] = json
            subject[:json].should == { "current_user" => { "id" => 1 } }
          end

          it "set the hash for xml" do
            subject[:xml] = xml
            subject[:xml].should == { "current_user" => { "id" => 1 } }
          end

          it "set the hash for a ruby hash" do
            subject[:ruby_hash] = ruby_hash
            subject[:ruby_hash].should == { current_user: { id: 1 } }.with_indifferent_access
          end
        end

        context "merge!" do
          let(:age_metadata) { Metadata.new age: 10 }
          let(:name_metadata) { Metadata.new name: "tom" }

          it "merges a different key" do
            subject.merge! age_metadata
            subject.attributes.should == { age: 10, name: "jon" }.with_indifferent_access
          end

          it "merges a similar key" do
            subject.merge! name_metadata
            subject.attributes.should == { name: "tom" }.with_indifferent_access
          end
        end

        context "setting objects" do
          it "set the object value" do
            subject[:name].should == "jon"
            subject["name"].should == "jon"
          end
        end

        context "display" do
          its(:display) { should == { name: "jon" }.with_indifferent_access }
          its(:display?) { should == true }
        end

        context "formatting" do
          its(:to_json) { should == { name: "jon" }.to_json }
          its(:to_xml) { should == { name: "jon" }.to_xml(skip_instruct: true, root: :metadata) }
        end
      end
    end
  end
end
