#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

# Load the bundled environment
require 'rubygems'
require 'bundler/setup'

# NOTE: plugin_job needs to be installed on the system to be run from this project
require 'cad_util'

CadUtil::run
