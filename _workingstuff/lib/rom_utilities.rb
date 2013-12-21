# rev 2012_11_15
require 'pathname'
require 'fileutils'
require 'win32/registry'
require "Win32API"

begin
    require 'parseconfig'
    raise "ParseConfig v1.0.2 required - please update (#{ParseConfig::Version})" if ParseConfig::Version<"1.0.2"
rescue LoadError
    raise "requires 'ParseConfig'\nDo 'gem install parseconfig'"
end

# Default-Path
# ! Store correct path in a seperated file

 # http://github.com/McBen/FDB_Extractor2
    $fdb_ex ||= "bin/FDB_ex2.exe"
 # http://www.lua.org
    $lua ||= "bin/lua5.1.exe"

raise '$fdb_ex variable not set or file not found' if not File.exists? $fdb_ex

###############
def TempPath()
    return File.join(ENV['TEMP'], 'rom/')
end

###############
def LUA_Execute(script)
    raise '$lua variable not set or file not found' if not File.exists? $lua
    system("#{$lua} "+script)
end

###############
# Options are: export_path, fdb_filter, silent, sql, regex
def Extract(path, filter="", options=Hash.new)

    # prepare options
    temp_path = options.fetch(:export_path,TempPath())
    raise "export_path is invalid" if TempPath().nil? || TempPath().empty?

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
    if options[:list] then
        Dir.chdir( Pathname($fdb_ex).dirname ) {

            data=[]
            output = IO.popen("#{$fdb_ex} #{foptions.join(" ")} -l #{escaped} #{src}")
            output.each_line {|s|
                next if s=~/^using RoM.*/
                data.push(s.chop.match(/^\"(.*)\"$/)[1])
            }
            return data
        }
    else
    	fdbex = Pathname($fdb_ex)
        Dir.chdir( fdbex.dirname ) {
        exe = fdbex.basename

        #p ("#{exe} #{foptions.join(" ")} -y -o \"#{temp_path}\" #{escaped} #{src}")
        if options.key?(:silent)
            `#{exe} #{foptions.join(" ")} -y -o \"#{temp_path}\" #{escaped} #{src}`
            raise "error" if $?!=0
        else
            result = system("#{exe} #{foptions.join(" ")} -y -o \"#{temp_path}\" #{escaped} #{src}")
            raise "error" unless result
        end
        }
    end

    return temp_path+path
end

###############
def ExtractDBFile(filename, options=Hash.new)
    filename += ".db" unless filename=~/\.db$/

    options[:fdb_filter]="data.fdb"

    dir = TempPath()+"data/"
    dir = Extract("data\\",filename,options) unless File.exists?(TempPath()+"data\\#{filename}.csv")

    return dir+filename+".csv"
end

###############
def RoMPath()
    begin
        dir = Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Frogster Interactive Pictures\Runes of Magic')["RootDir"]
    rescue
        dir = File.join(ENV['ProgramFiles'], "Runes of Magic/")
    end

    dir.gsub!('\\','/')
    unless File.exists?(dir)
        # go to parent path and check for Client.exe
        pc = Dir.pwd.split('/')
        dir = pc.shift
        while(tmp = pc.shift) do
            dir = File.join(dir, tmp)
            break if File.exists?(File.join(dir, 'Client.exe'))
        end
    end

    raise "RoM not found" unless File.exists?(dir)
    return dir + '/'
end

###############
def GetROMVersion()
    ini = ParseConfig.new(RoMPath() + "Client.exe.ini")
	return ini['Version'].values_at('Major', 'Minor', 'BuildNum', 'Extend').map {|x| x.to_i }
end

###############
def CheckTempPath()
    version = ""
    begin
        open(TempPath()+"version","rt")  {|f| version=f.gets }
    rescue
    end

    game_version = GetROMVersion()

    if game_version.to_s != version then
        p "removing old temp files"
        FileUtils.rm_rf TempPath()
    end

    FileUtils.mkdir_p(TempPath())
    open(TempPath()+"version","wt+")  {|f| f << game_version }
end
