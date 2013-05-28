require "spec_helper"

module CadUtil

  describe ModelDoc do
    context "with nil model" do
      subject(:model){ModelDoc.new nil}

      it "has a save method" do
        expect(model.respond_to?(:save)).to be_true
      end
    end # with nil model

    describe "opening a file" do
      context "given a valid path" do
        let(:path){File.join(SPEC_DATA_ROOT, 'Gasket.SLDPRT')}
        subject(:model){ModelDoc.path_open(path)}

        it "is a valid model" do
          expect(model).to_not be_nil
        end

      end # "given a valid path"

      context "given an invalid path" do

      end # givena an invalid path
    end
  end # describe ModelDoc

end