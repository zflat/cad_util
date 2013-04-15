$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rspec'
require 'cad_util'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|

  # Testing CLI
  # See
  # https://github.com/docwhat/homedir/blob/homedir3/spec/spec_helper.rb
  # https://github.com/docwhat/homedir/blob/homedir3/spec/lib/homedir/cli_spec.rb
  # https://github.com/wycats/thor/blob/master/spec/thor_spec.rb
  # http://stackoverflow.com/questions/12673485/how-to-test-stdin-for-a-cli-using-rspec
  # Different implementation for #capture
  # http://rails-bestpractices.com/questions/1-test-stdin-stdout-in-rspec

  # Captures the output for analysis later
  #
  # @example Capture `$stderr`
  #
  #     output = capture(:stderr) { $stderr.puts "this is captured" }
  #
  # @param [Symbol] stream `:stdout` or `:stderr`
  # @yield The block to capture stdout/stderr for.
  # @return [String] The contents of $stdout or $stderr
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  # Silences the output stream
  #
  # @example Silence `$stdout`
  #
  #     silence(:stdout) { $stdout.puts "hi" }
  #
  # @param [IO] stream The stream to use such as $stderr or $stdout
  # @return [nil]
  alias :silence :capture

end
