require 'fileutils'
require 'set'

require_relative 'rom_utilities'

# Pathes
$temp_path="e:/Temp/ro/"  # will be deleted !

######################################
CheckTempPath()

base_dir = $temp_path+"data/"
base_dir = Extract("data\\","*.db", {:fdb_filter=>"data.fdb", :sql=>true} )

Dir[base_dir+"*.sql"].each { |f|
    p f
    `sqlite3.exe -batch db.db <"#{f}"`
    }



