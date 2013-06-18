require 'clipboard'
require 'cad_util/connections/context_active_model'

module CadUtil
  module Utility
    class CopyFname < CadWorker

      include Connection::ContextActiveModel

      def run_utility
        name = model.GetPathName
        Clipboard.copy name
        log.info name
      end

      private

      def validate
        !model.nil?
      end

    end # class SaveCopy
  end # module Utility

end # module CadUtil
