require 'pathname'
require 'fileutils'
begin
    require 'parseconfig'
rescue LoadError
    raise "requires 'parseconfig'\nDo 'gem install parseconfig'"
end

require 'win32/registry'
require "Win32API"

# Tools
$fdb_ex="e:/Projekte/fdb_ex2/bin/FDB_ex2.exe " # ask McBen for it :)
$lua="e:/Tools/lua/lua5.1.exe " # www.lua.org

###############
def LUA_Execute(script)
    system("#{$lua} "+script)
end


###############
# Options are: export_path, fdb_filter, silent, sql, regex
def Extract(path, filter="", options=Hash.new)

    # prepare options
    temp_path = options.fetch(:export_path,$temp_path)
    raise "requires '$temp_path' or option:export_path" if temp_path.nil? || temp_path.empty?

    fdb_filters = options.fetch(:fdb_filter,"*.fdb")

    foptions=[]
    foptions.push("-v") unless options.key?(:silent)
    foptions.push("-s") if options[:sql]
    foptions.push("-r") if options[:regex]

    # prepare pathes
    src = "\"#{RoMPath()}fdb/#{fdb_filters}\""
    path.gsub!(/\\/,"/")
    escaped = path
    escaped.gsub!(/\//,"\\\\\\\\") if options[:regex]
    escaped = '^' + escaped if options[:regex]

    escaped = escaped+filter

    # do it
    Dir.chdir( Pathname($fdb_ex).dirname ) {
        #p ("#{$fdb_ex} #{foptions.join(" ")} -y -o \"#{temp_path}\" #{escaped} #{src}")
        system("#{$fdb_ex} #{foptions.join(" ")} -y -o \"#{temp_path}\" #{escaped} #{src}")
    }

    return temp_path+path
end


###############
def GetStringList(lang)
    fname = "string_"+lang+".db"
    base_dir = $temp_path+"data/"
    base_dir = Extract("data\\",fname,{:fdb_filter=>"data.fdb"}) unless File.exists?(base_dir+fname)
    return ParseConfig.new(base_dir+fname)
end

###############
def RoMPath()
    begin
        dir = Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Frogster Interactive Pictures\Runes of Magic')["RootDir"]
    rescue
        dir = "d:/Program Files (x86)/Runes of Magic/"
    end

    raise "RoM not found" unless File.exists?(dir)

    return dir
end

###############
def GetROMVersion()

    apiGetFileVersionInfoSize = Win32API.new('Version', 'GetFileVersionInfoSize', 'PP', 'L')
    apiGetFileVersionInfo     = Win32API.new('Version', 'GetFileVersionInfo', 'PLLP', 'L')
    apiVerQueryValue          = Win32API.new('Version', 'VerQueryValue', 'PPPP', 'I')
    memcpy = Win32API.new('msvcrt', 'memcpy', 'PLL', 'L')

    filename = RoMPath()+"Client.exe"

    vsize=apiGetFileVersionInfoSize.call(filename, nil)
    raise "no version info" if vsize==0

    infoVersion  = '\0' * vsize
    apiGetFileVersionInfo.call(filename,0,vsize,infoVersion)

    addr = "\0"*4
    value = "\0"*4
    apiVerQueryValue.call(infoVersion, '\\', addr, value)

    v_bufsz = value.unpack('L')[0]
    v_buf = "\0" * v_bufsz
    v_src = addr.unpack('L')[0]

    ret = memcpy.call(v_buf, v_src, v_bufsz)
    raise 'memcpy failed' if ret == 0
    raise 'Oops' unless v_buf[0, 4].unpack('L')[0] == 0xFEEF04BD

    return v_buf[0x08, 8].unpack('S*').values_at(1,0,3,2)  #-> [1, 8, 2, 0]
    # p v_buf[0x08, 8].unpack('S*').values_at(1,0,3,2)  #-> [1, 8, 2, 0]
    # p v_buf[0x10, 8].unpack('S*').values_at(1,0,3,2)  #-> [1, 8, 2, 0]
end

###############
def CheckTempPath()
    version = ""
    begin
        open($temp_path+"version","rt")  {|f| version=f.gets }
    rescue
    end

    game_version = GetROMVersion()

    if game_version.to_s != version then
        p "removing old temp files"
        FileUtils.rm_rf $temp_path
    end

    FileUtils.mkdir_p($temp_path)
    open($temp_path+"version","wt+")  {|f| f << game_version }
end
