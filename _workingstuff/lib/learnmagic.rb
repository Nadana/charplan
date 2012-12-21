require 'csv'
require_relative 'rom_utilities'

class SkillEntry
    attr_reader :skill
    attr_reader :min_level
    attr_reader :req_flag
    attr_reader :req_skill
    attr_reader :req_skill_lvl
    attr_reader :u1
    attr_reader :u3

    def initialize(csv_row)
        @skill = csv_row['skill'].to_i
        @min_level = csv_row['min_level'].to_i
        @req_flag = csv_row['req_flag'].to_i
        @req_skill = csv_row['req_skill'].to_i
        @req_skill_lvl = csv_row['req_skill_lvl'].to_i
        @u1 = csv_row['u1'].to_i
        @u3 = csv_row['u3'].to_i
    end

    def Export()
        return "{#{@min_level},#{@skill},#{@req_skill},#{@req_skill_lvl},#{@req_flag},}"
    end
end

class Learnmagic
    attr_reader :guids
    attr_reader :base
    attr_reader :spec

    def initialize()
        print("learnmagic: Extracting")
        base_dir = TempPath()+"data\\"
        base_dir = Extract("data\\","learnmagic.db",{:fdb_filter=>"data.fdb"})  unless File.exists?(base_dir+"learnmagic.db.csv")

        print(",Reading")
        @guids = Set.new()
        @spec = Read(base_dir+"learnmagic.db_spmagic.csv")
        @base = Read(base_dir+"learnmagic.db_normalmagic.csv")

        print(",done\n")
    end

    def Read(filename)
        r = {}
        csv = CSV.read(filename, {:col_sep=>";", :headers=>true, :converters => :numeric})
        csv.each { |row|
            guid = row['guid'].to_i
            @guids.add(guid)
            r[guid] =[] unless r.has_key? guid
            r[guid].push( SkillEntry.new(row) )
        }
        return r
    end

    def Export(filename)

        File.open(filename, 'wt') { |outf|
            outf.write( "-- learn: \n")

            outf.write("return {\n")
            @guids.each { |guid|

                line_base=[]
                if @base.has_key? guid then
                    @base[guid].sort {|x,y| x.min_level <=> y.min_level}.each {|r| line_base.push(r.Export()) }
                end

                line_spec=[]
                if @spec.has_key? guid then
                    @spec[guid].sort {|x,y| x.min_level <=> y.min_level}.each {|r| line_spec.push(r.Export()) }
                end

                outf.write( "  [%i]={{%s},{%s}},\n" % [guid, line_base.join(","),line_spec.join(",")])
            }
            outf.write("}\n")
        }
    end
end