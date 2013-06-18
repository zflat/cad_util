require 'plugin_job'

module CadUtil

  # Specialized worker that creates the
  # job context at the run step
  class CadWorker < PluginJob::Worker

    attr_reader :context

    def run
      run_utility
    end

    # NOTE: the context is created in the run step when valid
    # is checked because connections made in other steps (like setup)
    # are in a different thread and do not translate over
    def valid?
      @context = JobContext.new(self)
      return validate
    end

    private

    # Override to provide preconditions checking
    def validate
      true
    end

  end
end
