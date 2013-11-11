require 'benchmark'

puts Benchmark.measure{
  require "win32ole"
  require "basic_decorator"
  require "cad_util/version"
  puts "Loaded CadUtil dependencies 1"
}

puts Benchmark.measure{
  require "plugin_job"
  puts "Loaded CadUtil dependencies plugin_job"
}

puts Benchmark.measure{
  require "cad_util/adapters/constants"
  puts "Loaded CadUtil cad_util/adapters/constants"
}
  
puts Benchmark.measure{
  require "cad_util/adapters/as_ref_arg"
  require "cad_util/adapters/model_doc"
  require "cad_util/job_context"
  require "cad_util/cad_worker"
  puts "Loaded CadUtil dependencies 4"
}

require "log4r"
include Log4r

module CadUtil

  # Config utilities
  Dir[File.join(File.dirname(__FILE__), "cad_util", "utilities", "*.rb")].each {|f| require f}

  ################
  # Set up the Log

  puts Benchmark.measure{
    @log = Logger.new 'dispatcher'
    if ARGV.include?('stdout')
      @log.outputters = Outputter.stdout
    end
    puts "Setup the log"
  }

  puts Benchmark.measure{
  @plugins = PluginJob::PluginCollection.new({
                                         'MainCategory' =>
                                         ['SavePreview',
                                           'SaveCopy',
                                           'RandomColorChange',
                                           'CopyFname']},
                                       CadUtil::Utility)
     puts "Build the plugins list"                                    
   }

  #######################
  # Create the controller
  
  puts Benchmark.measure{
    require "plugin_job/hosts/gui_host"
    @controller = PluginJob::HostController.new(PluginJob::GuiHost, @plugins, @log)
    puts "Create the controller"
  }

  ###################
  # Set up the server
  
  puts Benchmark.measure{
    @server_config = {"host_ip" => "localhost", "port" => 3333}
    @server = PluginJob::Dispatcher.new(@controller, @server_config)
    puts "Set up the server"
  }
  
  def CadUtil.run
    #####################
    # Run the application
    @server.exec_app
  end

end
