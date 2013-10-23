require "cad_util/utilities/widgets/save_copy_widget"
require 'cad_util/connections/context_active_model'

module CadUtil
  module Utility
    class SaveCopy < CadWorker

      include Connection::ContextActiveModel

      def run_utility
        @widget.fpath.setText fname_0
        @waiting_for_input = true

        # Block until process called
        while(@waiting_for_input)
          sleep 0.01
        end

        # Perform a Save-as
        log.info("Saving as #{@fname_1}")
        model.save_as(@fname_1)

        # Open the newly saved file
        new_file = ModelDoc.path_open(@fname_1, context)

        # Change the color of the new file
        new_file.change_color
        new_file.ForceRebuild3(true)

        # Save the new file with SaveAsSilent to force color change
        # new_file.save
        # See https://forum.solidworks.com/thread/52728
        new_file.save_as_silent(@fname_1, false)

        # Force color to change by closing then opening
        log.info("Closing then reopening file to force color change")
        new_file.close
        new_file = ModelDoc.path_open(@fname_1, context)
        new_file.ForceRebuild3(true)
        new_file.save
      end

      def widget
        # Create the widget to prompt for the new file name
        if @widget.nil?
          @widget = SaveCopyWidget.new
          @widget.btn_box.connect(SIGNAL("accepted()")){
            process
          }
        end
        @widget
      end

      private

      def validate
        !model.nil?
      end

      def process
        # Get the new file name
        name = @widget.fpath.text

        # Check for conflicting name
        if FileTest.exists? name
          log.warn("File #{name} already exists")
        else
          # Assign the file name
          @fname_1 = name
          @waiting_for_input = false
        end
      end

      def fname_0
        model.GetPathName
      end
    end # class SaveCopy
  end # module Utility
end # module CadUtil
