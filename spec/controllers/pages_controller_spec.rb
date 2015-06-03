require 'spec_helper'
Page = Class.new
describe PagesController do
  it "gets json" do
    get :show, format: :json
    subject.send(:_layout).should == "axel"
  end

  it "gets xml" do
    get :show, format: :xml
    subject.send(:_layout).should == "axel"
  end

  it "doesn't get any" do
    get :show # This helper defailts to html which we haven't specified to handle
    response.code.should == "406"
  end

  its(:metadata) { should be_a Axel::Payload::Metadata }

  context "rescue error" do
    context "list of errors and 403" do
      let(:messages) { ["Broke 1", "Broke 2"] }
      let(:params) { { format: :json } }
      before do
        subject.stub respond_to: true
        subject.rescue_error messages: messages, status: :forbidden
      end

      it "sets error object" do
        subject.errors.display.should == { status: 403, messages: messages }
      end
    end
  end

  context "query helpers" do
    its(:query_params) { should be_a HashWithIndifferentAccess }
    its(:post_params) { should be_a HashWithIndifferentAccess }
  end

  context "formatters" do
    context "format" do
      its(:format) { should == :json }
      its(:render_nil_format) { should be_nil }
      context "with format param" do
        before { subject.stub params: { format: :xml } }

        its(:format) { should == :xml }
        its(:render_nil_format) { should == "" }
      end
    end
  end

  context "rabl render" do
    let(:string) { "" }
    it "asks rabl to render" do
      Rabl.should_receive(:render).with string, "view", view_path: "app/views", scope: subject
      subject.rabl_render string, "view"
    end
  end

  context "xml_clean" do
    let(:non_dirty) { <<-XML
<document>
  <metadata>
    <current_user nil="true"/>
  </metadata>
  <result>
  </result>
</document>
    XML
    }

    let(:dirty) { <<-XML
<document>
  <metadata>
    <?xml version="1.0" encoding="UTF-8"?>
    <hash>
      <current_user nil="true"/>
    </hash>
  </metadata>
  <result>
  </result>
</document>
    XML
    }

    let(:cleaned) { <<-XML
<document>
  <metadata>
    
          <current_user nil="true"/>
      </metadata>
  <result>
  </result>
</document>
    XML
    }

    it "doesn't touch the non_dirty" do
      subject.xml_clean(non_dirty).should == non_dirty.strip
    end

    it "cleans the dirty payload" do
      subject.xml_clean(dirty).should == cleaned.strip
    end
  end

  context "render action" do
    context "method" do
      let(:formatter) { double }
      it "calls formatter with action" do
        subject.should_receive(:respond_with).and_yield formatter
        subject.should_receive(:render).with({ action: :show}).twice
        formatter.should_receive(:json).and_yield
        formatter.should_receive(:xml).and_yield
        subject.respond_with_action(:show)
      end
    end

    context "id param" do
      let(:page) { Page.new }
      context "found record" do
        before do
          subject.stub params: { id: 1 }
          Page.should_receive(:where).with(:id => 1).and_return [page]
        end

        its(:find_resource) { should == page }
      end

      context "no record" do
        let(:page) { Page.new }
        before do
          subject.stub params: { id: 1 }
          Page.should_receive(:where).with(:id => 1).and_return []
        end

        it "raises not found" do
          expect { subject.find_resource }.to raise_error Axel::RecordNotFound
        end
      end

      context "with custom finder and value" do
        before do
          subject.stub params: { id: 1 }
          Page.should_not_receive(:where).with(:id => 1)
          Page.should_receive(:where).with(:name => "two").and_return [page]
        end

        it "raises not found" do
          subject.find_resource(finder: :name, value: "two").should == page
        end
      end
    end
  end

  context "drop meta" do
    context "doesn't drop meta" do
      its(:drop_meta?) { should be_falsey }
    end

    context "drops meta" do
      before do
        subject.drop_meta!
      end

      its(:drop_meta?) { should be_truthy }
    end
  end

  context "object_params" do
    context "nested in object name" do
      before do
        subject.stub post_params: { page: { id: 1 } }.with_indifferent_access
      end

      its(:object_params) { should == { id: 1 }.with_indifferent_access }
    end

    context "not nested in name" do
      before do
        subject.stub post_params: { id: 1 }.with_indifferent_access
      end

      its(:object_params) { should == { id: 1 }.with_indifferent_access }
    end
  end

  context "object_name" do
    its(:object_name) { should == "page" }
  end

  context "force_ssl!" do
    its(:force_ssl!) { should be_truthy }

    context "productionish" do
      before do
        Rails::Application.stub productionish?: true
      end

      it "raises force ssl error" do
        expect { subject.force_ssl! }.to raise_error Axel::ForceSSL
      end
    end
  end

  describe "safe_json_load" do
    it "loads a string of json" do
      subject.safe_json_load("{ \"user\": true }").should == { "user" => true }
    end

    it "returns nil for no json" do
      subject.safe_json_load(nil).should == nil
    end
  end
end
