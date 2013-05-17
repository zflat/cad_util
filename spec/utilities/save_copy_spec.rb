require "spec_helper"
require "cad_util/utilities/save_copy"

module CadUtil
  module Utility
  describe SaveCopy do
      subject(:util){SaveCopy.new}

      it "has a working directory" do
        expect(util.get_current_working).to_not be_nil
      end

    end # describe SaveCopy
  end # module Utility
end # module CadUtil
