require 'cad_util/connections/context_active_model'
module CadUtil
  module Utility
    class RandomColorChange < CadWorker

      include Connection::ContextActiveModel

      def run_utility
        model.change_color
        model.ForceRebuild3(true)
        log.info "Color Changed"
      end # run_utility

      private

      def validate
        !model.nil?
      end

    end # class RandomColorChange
  end # module Utility
end # module CadUtil
