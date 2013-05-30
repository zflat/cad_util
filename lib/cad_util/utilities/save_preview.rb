require 'cad_util/connections/context_active_model'

module CadUtil
  module Utility
    class SavePreview < CadWorker

      include Connection::ContextActiveModel

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

      def set_preview
        model.show_isometric
        model.zoom_fit
      end

    end # class SaveCopy
  end # module Utility

end # module CadUtil
