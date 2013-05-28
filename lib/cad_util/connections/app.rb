module CadUtil

  module Connection

    module App

      class Conxn
        include App
      end

      def self.connection
        @con ||= Conxn.new
      end

      def self.doc_type(fname)
        case File.extname(fname)[1..-1].downcase
        when 'sldasm'
          SldConst::SwDocASSEMBLY
        when 'sldprt'
          SldConst::SwDocPART
        when 'slddrw'
          SldConst::SwDocDRAWING
        else
          SldConst::SwDocNONE
        end
      end

      def doc_type(fname)
        App.doc_type(fname)
      end

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
        blnret = app.SetCurrentWorkingDirectory(dirpath)
      end

    end # module App

  end # module Connection
end # module CadUtil
