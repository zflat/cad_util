require "win32ole"
require "basic_decorator"
require "cad_util/version"
require "cad_util/adapters/constants"
require "cad_util/adapters/as_ref_arg"
require "cad_util/adapters/model_doc"
require "cad_util/job_context"
require "cad_util/cad_worker"
require "plugin_job"

require "log4r"
include Log4r

module CadUtil

  # Config utilities
  Dir[File.join(File.dirname(__FILE__), "cad_util", "utilities", "*.rb")].each {|f| require f}

  ################
  # Set up the Log

  @log = Logger.new 'dispatcher'
  if ARGV.include?('stdout')
    @log.outputters = Outputter.stdout
  end

  @plugins = PluginJob::Collection.new({
                                         'MainCategory' =>
                                         ['SavePreview', 'CopyFname']},
                                       CadUtil::Utility)

  #######################
  # Create the controller
  require "plugin_job/hosts/gui_host"
  @controller = PluginJob::HostController.new(PluginJob::GuiHost, @plugins, @log)

  ###################
  # Set up the server
  @server_config = {"host_ip" => "localhost", "port" => 3333}
  @server = PluginJob::Dispatcher.new(@controller, @server_config)

  def CadUtil.run
    #####################
    # Run the application
    @server.exec_app
  end

end
