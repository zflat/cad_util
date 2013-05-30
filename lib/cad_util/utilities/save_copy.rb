require "cad_util/utilities/widgets/save_copy_widget"
require 'cad_util/connections/context_active_model'

module CadUtil
  module Utility
    class SaveCopy < CadWorker

      include Connection::ContextActiveModel

      def valid?
        !model.nil?
      end

      def run_utility
        @widget.fpath.setText fname_0
        # Get the new file name
        # Perform a Save-as
        # Open the newly saved file
        # Change the color of the new file
      end

      def widget
        # Create the widget to prompt for the new file name
        if @widget.nil?
          @widget = SaveCopyWidget.new
        end
        @widget
      end

      private

      def fname_0
        model.GetPathName
      end
    end # class SaveCopy
  end # module Utility
end # module CadUtil
