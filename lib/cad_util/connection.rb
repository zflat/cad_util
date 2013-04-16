module CadUtil

  module Connection

    def pdm
      if @pdm.nil?
        @pdm = WIN32OLE.new('PDMWorks.PDMWConnection')
        # @connection.Login 'wwedler', 'Aquion12', '172.20.100.13'
        unless @pdm.nil?
          @pdm.Login *CadUtil.configuration.login_creds
        end
      end
      return @pdm
    end # pdm

    def app
      @app ||= WIN32OLE.new('SldWorks.Application')
    end # app

    def active_model
      ModelDoc.new app.ActiveDoc
    end

    def get_current_working
      app.GetCurrentWorkingDirectory
    end

  end # module Connection
end # module CadUtil
