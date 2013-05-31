require_relative "spec_host"

module CadUtil
  class SpecContext
    include PluginJob::LogBuilder

    attr_reader :app, :pdm
    def initialize
      @host = SpecHost.new
      init_log(@host.log, "SpecWorker")

      @app = Connection::App.new(self)
      @pdm = Connection::Pdm.new(self)
    end
  end
end
