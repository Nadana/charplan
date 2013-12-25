require 'fileutils'
require 'csv'
require_relative 'rom_utilities'
require_relative 'table'

class Image < TableEntry

    # Options
    BASE_ICON_PATH = "interface/icons/"

    # Data
    attr_reader :filename

    def initialize(row)
        super(row)
        @id = row['guid'].to_i
        @filename = row['actfield']

        if not @filename.nil? then
            @filename=nil if @filename=~/\/$/ # rom bug? icon is a directory
        end
    end

    def pathname()
        if not @filename.nil? then
            @filename.tr!('\\','\/')  # replace slash
            @filename.gsub!(/^\//,'') # remove leading slash
            @filename.downcase!       # using lower case to minimize mem usage

            @filename.gsub!(/\..+$/,'') # remove extention
        end
        return @filename
    end

    def pathnameShort()
        return pathname().gsub(/^#{Regexp.escape(BASE_ICON_PATH)}/,'')
    end

    def IsValid?
        return (not @filename.nil? and super())
    end

    def ExportDesc(data)
        data.push( "filename (base=#{BASE_ICON_PATH}")
    end

    def ExportData(data)
        #raise "image not on base path: "+@filename unless @filename=~/^#{Regexp.escape(BASE_ICON_PATH)}/
        data.push('"'+pathnameShort()+'"')
    end
end


class Images < Table
    FILENAME = "imageobject"

    def initialize()
        super(Image, FILENAME)
    end

    def MarkUnusedIfNotExists()
        print("Get Icon List\n")
        files = Extract("interface\\icons\\","",{:fdb_filter=>"interface.fdb", :list=>true})
        files.each {|d| d.gsub!(/\\/,"/").gsub!(/\..+$/,'') }

        MarkUnused { |data| not files.include?(data.filename) }
    end
end



