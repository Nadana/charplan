require 'csv'
require_relative 'rom_utilities'

def FormatArray(array, optimize=false)
    if array.nil? or array.size<=0 then
        return "nil"
    end

    if optimize and array.size==1 then
        return array[0]
    end

    return "{" + array.join(",") + "}"
end

def Val(val)
    return (not val or val.nil?) ? "nil" : val.to_s
end


class TableEntry
    attr_reader :id
    attr_accessor :used

    def initialize(csv_row)
        @id = csv_row['guid'].to_i
        @used = true
    end

    def IsValid?
        return (@id!=0)
    end

    def Export?
        return (IsValid? and @used)
    end

    def IsUsed()
        return @used
    end

    def Used()
        @used = true
    end

    def NotUsed()
        @used = false
    end

    def ExportDesc(data)
    end

    def ExportData(data)
        raise "no exposrt defined"
    end
end


class Table
    attr_reader :db

    def initialize(object, filename=nil)
        #raise "object must be TableEntry class" unless object.kind_of?(TableEntry)

        @ent_obj = object
        @db = Hash.new(object)

        filename = @ent_obj::FILENAME if filename.nil?
        Load(filename) unless filename.nil?
    end

    def MarkUnusedIf
        each { |data|
            data.NotUsed() if yield(data)
        }
    end

    def MarkAllUnused
        MarkUnusedIf {true}
    end

    def MarkUnusedIfNameInvalid(*locales)

        def Unknown?(id,locales)
            locales.each { |l| return false if l.include?(id) }
            return true
        end

        MarkUnusedIf { |data| Unknown?(data.id,locales) }
    end

    def Used(id)
        @db[id].Used()
    end

    def NotUsed(id)
        @db[id].NotUsed()
    end

    def Load(filename)
        print("#{filename}: Extracting")
        base_dir = TempPath()+"data\\"
        base_dir = Extract("data\\","#{filename}.db",{:fdb_filter=>"data.fdb"})  unless File.exists?(base_dir+"#{filename}.db.csv")

        print(",Reading")
        csv = CSV.read(base_dir+"#{filename}.db.csv", {:col_sep=>";", :headers=>true, :converters => :numeric})

        print(",Parsing")
        csv.each { |row|
            r = @ent_obj.new(row)
            next if not r.IsValid?
            @db[r.id]= r
        }

        print(",Evaluating")
        AfterLoad()

        print(",done\n")
    end

    def AfterLoad()
    end

    def include?(id)
        return (@db.include?(id) and @db[id].IsUsed)
    end

    def [](id)
        return @db[id] if @db[id].IsUsed
    end

    def each
        @db.each { |id,data| yield(data) if data.IsUsed  }
    end

    def merge!(db)
        @db.merge!(db.db)
    end

    def ExportEntry(entry)
        dest = []
        entry.ExportData(dest)
        return dest
    end

    def Export(filename)

        desc = Hash.new()
        maxdata=0
        @db.each { |id, data|
            if not desc.has_key?(data.class) then
                line_data = []
                data.ExportDesc(line_data)
                desc[data.class] = line_data.join(",")
                maxdata = [maxdata, line_data.size()].max
            end
        }

        File.open(filename, 'wt') { |outf|
            desc.each { |cl,d|
                outf.write( "-- %s: %s\n" % [cl.to_s,d])
                }

            outf.write("return {\n")
            db.each { |id, data|
                next if not data.Export?

                line_data = ExportEntry(data)

                while not line_data.empty? and (line_data.last=="nil" or line_data.last.to_s.empty?) do line_data.pop end

                if maxdata==1 then
                    outf.write( "  [%s]=%s,\n" % [id, line_data.join(",")])
                else
                    outf.write( "  [%s]={%s},\n" % [id, line_data.join(",")])
                end
                }
            outf.write("}\n")
        }
    end

    def GuessOrder()
    end
end

