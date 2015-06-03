require 'axel/request_options'
module Axel
  describe RequestOptions do
    subject { RequestOptions.new nil, example_options }
    let(:example_options) { {} }

    it "compiles with the default headers" do
      subject.compiled.should == {
        'headers' => {
          'Content-Type' => 'application/json'
        },
      }
    end

    describe "non-conflicting params" do
      let(:example_options) { { params: { id: 1 } } }
      it "compiles with the non-conflicting params" do
        subject.compiled.should == {
          'params' => { 'id' => 1 },
          'headers' => {
            'Content-Type' => 'application/json'
          },
        }
      end
    end

    describe "slightly-conflicting params" do
      let(:example_options) { { headers: { id: 1 } } }
      it "compiles with the non-conflicting params" do
        subject.compiled.should == {
          'headers' => {
            'id' => 1,
            'Content-Type' => 'application/json'
          },
        }
      end
    end

    describe "truly-conflicting params" do
      let(:example_options) { { headers: { "Content-Type" => 1 } } }
      it "compiles with the non-conflicting params" do
        subject.compiled.should == {
          'headers' => {
            'Content-Type' => 1
          },
        }
      end
    end
  end
end
