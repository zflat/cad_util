#!/usr/bin/env ruby -w

require 'win32ole'

connection = WIN32OLE.new('PDMWorks.PDMWConnection')
connection.Login 'wwedler', 'Aquion12', '172.20.100.13'

app = WIN32OLE.new('SldWorks.Application')

puts app.GetCurrentWorkingDirectory

puts app.ActiveDoc.GetPathName unless app.ActiveDoc.nil?

pdmdoc = connection.GetSpecificDocument('SP-STACK-0001.SLDASM')

puts pdmdoc.name
puts pdmdoc.project
puts pdmdoc.IsTopLevel

projs = connection.Projects

puts "Projects"
puts "________"
(0..projs.Count-1).to_a.each do |i|
  p =  projs.Item(i)
  puts p.name if p.parent.nil?
  # puts "  #{p.parent.name}" unless p.parent.nil?
end


# Wait for Ctrl+Z Enter
$stdin.read
