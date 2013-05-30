require "cad_util/connection"
require "plugin_job"

module CadUtil

  # Encapsulate the connections, log
  # and other context-related attributes
  # used by utilit#run and sub-routines
  class JobContext
    include PluginJob::LogBuilder

    attr_reader :app, :pdm
    def initialize(job)
      @job = job
      init_log(@job.log, "Worker")

      @app = Connection::App.new(self)
      @pdm = Connection::Pdm.new(self)
    end
  end # class JobContext
end
