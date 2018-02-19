#!/home/quentin/.rvm/rubies/default/bin/ruby

require 'json'

spotify_ws = '4 Music'
spotify_cmd = 'spotify'

current_ws = JSON.parse(`i3-msg -t get_workspaces`).select { |e| e['focused'] == true }.first['name']

`i3-msg workspace #{spotify_ws}` unless current_ws.eql?(spotify_ws)

system("#{spotify_cmd} &")
