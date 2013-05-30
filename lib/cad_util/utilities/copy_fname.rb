require 'clipboard'
require 'cad_util/connections/context_active_model'

module CadUtil
  module Utility
    class CopyFname < CadWorker

      include Connection::ContextActiveModel

      def valid?
        !model.nil?
      end

      def run_utility
        if valid?
          name = model.GetPathName
          Clipboard.copy name
          log.info name
        end
      end

    end # class SaveCopy
  end # module Utility

end # module CadUtil
