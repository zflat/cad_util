module CadUtil

  module Connection

    class App

      def initialize(context)
        @context = context
      end

      def active_model
        ModelDoc.new app.ActiveDoc
      end

      def get_current_working
        app.GetCurrentWorkingDirectory
      end

      def set_current_working(dirpath)
        blnret = app.SetCurrentWorkingDirectory(dirpath)
      end

      private

      def app
        # Use #new or use #connect  ?
        @app ||= WIN32OLE.new('SldWorks.Application')
      end # app

    end # Class App

  end # module Connection
end # module CadUtil
