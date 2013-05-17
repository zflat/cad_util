require "spec_helper"
require "cad_util/utilities/save_preview"

module CadUtil
  module Utility
    describe SavePreview do
      subject(:util){SavePreview.new}

      it "has an application" do
        expect(util.app).to_not be_nil
      end

      it "has a working directory" do
        expect(util.get_current_working).to_not be_nil
      end

      it "is valid" do
        expect(util.valid?).to be_true
      end

      it "can run" do
        expect(util.run).to be_nil
      end
    end # describe SaveCopy

  end # describe CopyFname
end # module CadUtil
