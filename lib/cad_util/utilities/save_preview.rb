module CadUtil
  module Utility
    class SavePreview < CadWorker

      def valid?
        !model.nil?
      end

      def run_utility
        set_preview
        model.save
      end

      def meta
        {:silent => true}.merge(super)
      end

      private

      def model
        if context && context.app
          @model ||= context.app.active_model
        end
      end

      def set_preview
        model.show_isometric
        model.zoom_fit
      end

    end # class SaveCopy
  end # module Utility

end # module CadUtil
