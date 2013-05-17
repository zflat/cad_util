
module CadUtil
  module Utility
    class SaveCopy
      include Connection

      def get_current_working
        app.GetCurrentWorkingDirectory
      end
    end # class SaveCopy
  end
end # module CadUtil
