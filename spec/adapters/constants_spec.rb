require "spec_helper"

module CadUtil

  describe SldConst do
    it "has a chamfer constant" do
      expect(SldConst::SwFmChamfer).to_not be_nil
    end

    it "has a doc type constant" do
      expect(SldConst::SwDocPART).to_not be_nil
    end
  end

end
