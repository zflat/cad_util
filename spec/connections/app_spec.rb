require "spec_helper"

module CadUtil

  module Connection
    describe App do
      let(:connection){App.connection}
      it "has a connection to the application" do
        expect(connection).to_not be_nil
      end

      it "has an active working directory" do
        expect(connection.get_current_working).to_not be_nil
      end

      describe "doc type" do
        context "part name" do
          let(:name){"abc.sldprt"}
          let(:type){Connection::App.doc_type(name)}

          it "determines part" do
            expect(type).to eq SldConst::SwDocPART
          end
        end # context "part name"

        context "assembly name" do
          let(:name){"abc.sldasm"}
          let(:type){Connection::App.doc_type(name)}

          it "determines assembly" do
            expect(type).to eq SldConst::SwDocASSEMBLY
          end
        end # context "assembly name"

        context "drawing name" do
          let(:name){"abc.slddrw"}
          let(:type){Connection::App.doc_type(name)}

          it "determines drawing" do
            expect(type).to eq SldConst::SwDocDRAWING
          end
        end # context "drawing name"

      end # describe "doc type"
    end # describe App
  end
end
