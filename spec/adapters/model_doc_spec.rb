require "spec_helper"

module CadUtil

  describe ModelDoc do
    context "with nil model" do
      subject(:model){ModelDoc.new(nil, nil)}

      it "is nil" do
        expect(model).to be_nil
      end
    end # with nil model

    describe "opening a file" do
      context "given a valid path" do
        let(:context){SpecContext.new}
        let(:original_path){File.join(SPEC_DATA_ROOT, 'Gasket.SLDPRT')}
        let(:fpath){File.join(SPEC_TMP_ROOT, 'Gasket.SLDPRT')}
        subject(:model){ModelDoc.path_open(fpath, context)}

        before :each do
          # copy file to temp path
          FileUtils.cp original_path, fpath
        end

        it "is a valid model" do
          expect(model).to_not be_nil
        end

        after :each do
          # close the temp file
          model.close

          # cleanup the files in the temp path
          FileUtils.rm [fpath]
        end # after :each
      end # "given a valid path"

      context "given an invalid path" do
      end # given an invalid path

    end  # describe "opening a file" do

    describe "changing color" do
      let(:context){SpecContext.new}
      let(:original_path){File.join(SPEC_DATA_ROOT, 'Gasket.SLDPRT')}
      let(:fpath){File.join(SPEC_TMP_ROOT, 'Gasket.SLDPRT')}
      subject(:model){ModelDoc.path_open(fpath, context)}
      let(:vals_0){model.MaterialPropertyValues}

      before :each do
        # copy file to temp path
        FileUtils.cp original_path, fpath
        vals_0 # force vals to load
      end

      after :each do
        # close the temp file
        model.close

        # cleanup the files in the temp path
          FileUtils.rm [fpath]
      end # after :each

      describe "setting with unchanged properties" do
        it "keeps the same properties" do
          model.MaterialPropertyValues= vals_0
          expect(model.MaterialPropertyValues).to eq vals_0
        end
      end

    end
  end # describe ModelDoc

end
