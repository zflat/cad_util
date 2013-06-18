require 'cad_util/connections/context_active_model'

module CadUtil
  module Utility
    class SavePreview < CadWorker

      include Connection::ContextActiveModel

      def run_utility
        set_preview
        model.save
      end

      def meta
        {:silent => true}.merge(super)
      end

      private

      def set_preview
        unless model.doc_type == SldConst::SwDocDRAWING
          model.show_isometric
        end
        model.zoom_fit
      end

      def validate
        !model.nil?
      end

    end # class SaveCopy
  end # module Utility

end # module CadUtil
