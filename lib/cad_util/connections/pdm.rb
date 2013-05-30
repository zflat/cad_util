module CadUtil

  module Connection
    class Pdm
      def initialize(context)
        @context = context
      end
      private
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
    end # module Pdm

  end
end
