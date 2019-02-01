#!/home/quentin/.rvm/rubies/default/bin/ruby

require 'json'

primary_output = JSON.parse(`i3-msg -t get_outputs`).select { |e| e['primary'] == true }.first['name']
used = JSON.parse(`i3-msg -t get_workspaces`).map { |e| e['num'] }
avail = ([*5..used.max]-used).first || used.max+1

`i3-msg workspace #{avail}; i3-msg move workspace to output #{primary_output}`
