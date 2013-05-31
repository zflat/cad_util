module CadUtil
  class SpecHost
    include PluginJob::LogBuilder
    include Log4r
    def initialize
      @log = Logger.new 'host'
    end
  end
end # module CadUtil
