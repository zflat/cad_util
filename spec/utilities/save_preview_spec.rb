require "spec_helper"
require "cad_util/utilities/save_preview"

module CadUtil
  module Utility
    describe SavePreview do
      let(:original_path){File.join(SPEC_DATA_ROOT, 'Gasket.SLDPRT')}
      let(:fpath){File.join(SPEC_TMP_ROOT, 'Gasket.SLDPRT')}
      let(:host){SpecHost.new}
      let(:part_model){ModelDoc.path_open(fpath)}

      subject(:util){SavePreview.new(host)}

      before :each do
        # copy file to temp path
        FileUtils.cp original_path, fpath

        # open the subject file in SW
        part_model
      end

      after :each do
        # close the temp file
        part_model.close

        # cleanup the files in the temp path
        FileUtils.rm [fpath]
      end

      context "before setup" do
        it "is not valid" do
          expect(util.valid?).to_not be_true
        end
      end

      context "after setup" do
        before :each do
          util.setup
        end
        it "is valid" do
          expect(util.valid?).to be_true
        end

        it "can run" do
          expect(util.run).to be_nil
        end

      end # context after setup

    end # describe SaveCopy

  end # describe CopyFname
end # module CadUtil
