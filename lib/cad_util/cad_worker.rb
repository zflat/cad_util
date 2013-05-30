require 'plugin_job'

module CadUtil

  # Specialized worker that creates the
  # job context at the run step
  class CadWorker < PluginJob::Worker

    attr_reader :context

    # NOTE: the context is created in the run
    # step because connections made in other steps (like setup)
    # are in a different thread and do not translate over
    def run
      @context = JobContext.new(self)
      run_utility
    end
  end
end
