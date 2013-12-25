require 'csv'
require_relative 'rom_utilities'

#module RoM_DB

def FormatArray(array, optimize=false)
    while not array.empty? and (array.last=="nil" or array.last.to_s.empty?) do array.pop end

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

    def IsUsed?
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
        raise "no export defined"
    end

    def Name(locales)
        return locales[@id]
    end

    def PrepareExport(table,*args)
    end

    def ExportNew(fields)
        res = fields.map { |x|
            r = method(x).call

            if r.is_a? Array
                FormatArray(r,true)
            elsif !!r==r # is Boolean?
                (r ? "1" : "nil")
            elsif r.nil?
                "nil"
            else
                r.to_s
            end
            }

        while not res.empty? and (res.last=="nil" or res.last.to_s.empty?) do res.pop end
        return res
    end

end


class Table
    attr_reader :db
    attr_reader :index

    def initialize(object, filename=nil)
        #raise "object must be TableEntry class" unless object.kind_of?(TableEntry)

        @ent_obj = object
        @db = [] # Array.new(0,object)
        @index = Hash.new()

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

        def Unknown?(entry,locales)
            locales.each { |l| return false unless entry.Name(l).nil?}
            return true
        end

        MarkUnusedIf { |data| Unknown?(data,locales) }
    end

    def Used(id)
        return false if not @index.include? id
        @db[@index[id]].Used()
    end

    def NotUsed(id)
        @db[@index[id]].NotUsed()
    end

    def Load(filename)
        print("#{filename}: Extracting")
        ex_filename = ExtractDBFile(filename,:silent=>true)

        print(",Reading")
        csv = CSV.read(ex_filename, {:col_sep=>";", :headers=>true, :converters => :numeric})

        print(",Parsing")
        csv.each { |row|
            r = @ent_obj.new(row)
            next if not r.IsValid?
            @index[r.id]= @db.size()
            @db.push(r)
        }

        print(",Evaluating")
        AfterLoad()

        print(",done\n")
    end

    def AfterLoad()
    end

    def include?(id)
        return (@index.include?(id) and @db[@index[id]].IsUsed?)
    end

    def exists?(id)
        return @index.include?(id)
    end

    def [](id)
        i = @index[id]
        #raise "undefined id:#{i}" if i.nil?
        return @db[i] if not i.nil? and @db[i].IsUsed?
    end

    def each
        @db.each { |data| yield(data) if data.IsUsed?  }
    end

    def select
        @db.select { |data| yield(data) if data.used?  }
    end

    def merge!(db)
        @db = @db+db.db
        @index.clear()
        @db.each_index{ |i| @index[@db[i].id]=i }
    end

    def ExportEntry(entry)
        dest = []
        entry.ExportData(dest)
        return dest
    end

   def ExportEntryDesc(entry)
        dest = []
        entry.ExportDesc(dest)
        return dest
    end

    def Export(filename)

        desc = Hash.new()
        maxdata=0
        @db.each { |data|
            if not desc.has_key?(data.class) then
                line_data = ExportEntryDesc(data)
                desc[data.class] = line_data.join(",")
                maxdata = [maxdata, line_data.size()].max
            end
        }

        File.open(filename, 'wt') { |outf|
            desc.each { |cl,d|
                outf.write( "-- %s: %s\n" % [cl.to_s,d])
                }

            outf.write("return {\n")
            @db.each { |data|
                next if not data.Export?

                line_data = ExportEntry(data)

                while not line_data.empty? and (line_data.last=="nil" or line_data.last.to_s.empty?) do line_data.pop end

                if maxdata==1 then
                    outf.write( "  [%s]=%s,\n" % [data.id, line_data.join(",")])
                else
                    outf.write( "  [%s]={%s},\n" % [data.id, line_data.join(",")])
                end
                }
            outf.write("}\n")
        }
    end

   def ExportNew(filename, fields,*args)
        File.open(filename, 'wt') { |outf|
            outf.write( "-- %s\n" % fields.join(", "))

            outf.write("return {\n")
            @db.each { |data|
                next if not data.Export?

                data.PrepareExport(self, args)
                line_data = data.ExportNew(fields)

                if fields.size==1 then
                    outf.write( "  [%s]=%s,\n" % [data.id, line_data.join(",")])
                else
                    outf.write( "  [%s]={%s},\n" % [data.id, line_data.join(",")])
                end
                }
            outf.write("}\n")
        }
    end

    def GuessOrder(fields, force_output=false,*args)

        data_count = Array.new
        @db.each { |data|
            next if not data.Export?

            data.PrepareExport(self, args)
            line_data = data.ExportNew(fields)
            while data_count.size < line_data.size do data_count.push(0) end

            line_data.each_with_index do |item, index|
                data_count[index] += 1 if item!="nil"
            end
        }

        order = (0..data_count.size-1).to_a
        neworder = order.sort { |a,b|
                (data_count[b] <=> data_count[a])==0 ? (a <=> b) :  (data_count[b] <=> data_count[a])
            }

        if force_output or order != neworder then
            #order_str = neworder.map { |i| "#{i+1}-#{fields[i]}" }.join(",")
            order_str = neworder.map { |i| "#{i+1}-#{fields[i]} (#{data_count[i]*100/@db.size}%)" }.join("\n")
            puts "Suggested order for #{self.class.name} ->\n#{order_str}"
        end
    end

    def WriteFieldDef(filename, marker, prefix, fields)

        list =""
        fields.each_with_index {|name,idx| list=list+"    local #{prefix}#{name.upcase}=#{idx+1}\n" }

        text= File.read filename
        text.force_encoding("UTF-8")

        str_begin = "--[[ [ #{marker} ]]"
        str_end = "--[[ ] ]]"

        old = /#{Regexp.escape(str_begin)}.+?#{Regexp.escape(str_end)}/mu
        new = str_begin+"\n"+ list + str_end

        text.gsub!(old,new)

        File.open(filename, 'w+'){ |f| f << text }

    end
end

