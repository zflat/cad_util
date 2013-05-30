require 'clipboard'

module CadUtil
  module Utility
    class CopyFname < CadWorker

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

      def model
        if context && context.app
          @model ||= context.app.active_model
        end
      end

    end # class SaveCopy
  end # module Utility

end # module CadUtil
