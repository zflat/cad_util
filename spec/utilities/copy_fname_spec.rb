require "spec_helper"
require "cad_util/utilities/copy_fname"

module CadUtil
  describe CopyFname do
    subject(:util){CopyFname.new}

    it "is valid" do
      expect(util.valid?).to be_true
    end

    it "can run" do
      expect(util.run).to_not be_nil
    end

  end
end
