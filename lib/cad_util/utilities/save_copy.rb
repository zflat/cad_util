
module CadUtil
  module Utility
    class SaveCopy < CadWorker

      def valid?
        !model.nil?
      end

      def setup
        fname_0 = model.GetPathName
        # Create the widget to prompt for the new file name
      end

      def run_utility
        # Get the new file name
        # Perform a Save-as
        # Open the newly saved file
        # Change the color of the new file
      end

    end # class SaveCopy
  end # module Utility
end # module CadUtil
