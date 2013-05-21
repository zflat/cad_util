#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

# Load the bundled environment
require 'rubygems'
require 'bundler/setup'

require 'cad_util'

CadUtil::run
