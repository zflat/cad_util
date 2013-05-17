require "win32ole"
require "basic_decorator"
require "cad_util/version"
require "cad_util/adapters/constants"
require "cad_util/adapters/as_ref_arg"
require "cad_util/adapters/model_doc"
require "cad_util/connection"
require "plugin_job"

module CadUtil

  # Config utilities
  Dir[File.join(File.dirname(__FILE__), "cad_util", "utilities", "*.rb")].each {|f| require f}

  ################
  # Set up the Log
  require "log4r"
  include Log4r
  log = Logger.new 'dispatcher'
  if ARGV.include?('stdout')
    log.outputters = Outputter.stdout
  end

  plugins = PluginJob::Collection.new({'MainCategory' => ['SavePreview']}, CadUtil::Utility)

  # Start the server
end
