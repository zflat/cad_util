module CadUtil
  module Connection
    module ContextActiveModel
      private
      def model
        if context && context.app
          @model ||= context.app.active_model
        end
      end # def model
    end # module ActiveModelFromContext
  end # module Connection
end # module CadUtil
