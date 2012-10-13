require_relative 'rom_utilities'

class Locales
    attr_accessor :db

    def initialize(lang)
        fname = "string_"+lang+".db"
        base_dir = TempPath()+"data/"
        base_dir = Extract("data\\",fname,{:fdb_filter=>"data.fdb"}) unless File.exists?(base_dir+fname)
        @db = ParseConfig.new(base_dir+fname)
    end

    def [](id)
        if id.is_a?(String) then
            name = @db["\"#{id}\""]
        else
            name = @db["\"Sys#{id}_name\""]
            name=nil if name=="" or name=="Sys#{id}_name"
        end

        return if name.nil?

        name.gsub!('\\\\','\\')
        name.gsub!('"','\\"')
        return name
    end

    def include?(id)
        return (not self[id].nil?)
    end

    def each
        @db.params.each { |k,v| yield k,v}
    end
end

