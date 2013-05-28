module CadUtil

  module Connection

    module App

      def app
        @app ||= WIN32OLE.new('SldWorks.Application')
      end # app

      def active_model
        ModelDoc.new app.ActiveDoc
      end

      def get_current_working
        app.GetCurrentWorkingDirectory
      end

      def set_current_working(dirpath)
        app.SetCurrentWorkingDirectory(dirpath)
      end

    end # module App

  end # module Connection
end # module CadUtil
