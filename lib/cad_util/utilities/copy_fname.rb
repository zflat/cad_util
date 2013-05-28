require 'clipboard'
require 'plugin_job'

module CadUtil
  module Utility
    class CopyFname < PluginJob::Worker
      include Connection::App

      attr_reader :model

      def valid?
        !model.nil?
      end

      def run
        @model ||= active_model
        if valid?
          name = model.GetPathName
          Clipboard.copy name
          log.info name
        end
      end

    end # class SaveCopy
  end # module Utility

end # module CadUtil
