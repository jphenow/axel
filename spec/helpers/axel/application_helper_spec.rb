require 'spec_helper'
module Axel
  describe ApplicationHelper do
    before do
      helper.stub drop_meta?: false
    end
    describe "page title" do
      it "is empty with no title locales implemented" do
        helper.page_title.should == ""
      end

      context "with locale hash" do
        let(:action_param) { "show" }
        let(:controller_param) { "pages" }
        let(:params) { { action: action_param, controller: controller_param } }
        let(:t) { { user: { pages: { show: "User Page Show" } }, pages: { show: "Page Show" } } }

        before do
          helper.stub t: t, params: params
        end

        it { helper.page_title.should == " - Page Show" }

        context "nested controller name" do
          let(:controller_param) { "user/pages" }
          it { helper.page_title.should == " - User Page Show" }
        end
      end
    end
  end
end
