# ps-chatbot: a chatbot that responds to commands on Pokemon Showdown chat
# Copyright (C) 2014 pickdenis
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require './triggers/autoban/banlist.rb'

Trigger.new do |t|
  t[:id] = "viewbanlist"
  t[:nolog] = true
  
  t.match { |info|
    (info[:where].downcase == 'pm' || info[:where] == 's') &&
    info[:what] =~ /^banlist (.*?)$/ && $1
  }
  
  uploader = CBUtils::HasteUploader.new
  
  t.act do |info|
    room = $1
    bl = BLHandler::Lists[$1]
    
    if !bl
      info[:respond].call("I don't have a banlist for that room.")
    end
    
    next if !['#', '@', '%'].index(Userlist.get_user_group(info[:who]))

    bl_data = bl.banlist.join("\n")
    
    banlist_text = if bl_data.strip.empty?
      'nobody'
    else
      bl_data
    end
    
    uploader.upload(banlist_text) do |url|
      info[:respond].call(url)
    end
    
  end
end
