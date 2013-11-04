#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

# name the ruby program
$0 = "util_launcher"

gemfile_path = File.join(File.dirname(__FILE__), 'Gemfile')
# Dir.chdir File.dirname(gemfile_path)
ENV['BUNDLE_GEMFILE'] = gemfile_path

# Load the bundled environment
require 'rubygems'
require 'bundler/setup'

# NOTE: plugin_job needs to be installed on the system to be run from this project
require 'cad_util'

CadUtil::run
