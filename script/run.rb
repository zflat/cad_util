#!/usr/bin/env ruby
require 'benchmark'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

# name the ruby program
$0 = "util_launcher"

gemfile_path = File.join(File.dirname(__FILE__), 'Gemfile')
# Dir.chdir File.dirname(gemfile_path)
ENV['BUNDLE_GEMFILE'] = gemfile_path
ENV['SCRIPT_ENTRY'] = File.dirname(__FILE__)

# Load the bundled environment
require 'rubygems'

puts Benchmark.measure{ 
  require 'bundler'
  Bundler.setup(:default)
  puts "Bundler setup"
}

# NOTE: plugin_job needs to be installed on the system to be run from this project
puts Benchmark.measure{
  require 'cad_util'
  puts "Loaded cad_util"
}

CadUtil::run
