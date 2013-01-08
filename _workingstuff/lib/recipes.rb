require_relative 'table'

#module RoM_DB

class RecipesEntry < TableEntry

    attr_accessor :skill
    attr_accessor :level
    attr_accessor :sources,:results
    attr_accessor :res_item1
    attr_accessor :res_item1_count

    def initialize(csv_row)
        super(csv_row)
        @skill = (csv_row["requestskill"].to_i) -14
        @level = csv_row["requestskilllv"].to_i
        @res_item1 = csv_row["item1_normal"].to_i
        @res_item1_count = csv_row["item1_normalcount"].to_i

        @sources = getSources(csv_row)
        @results = getResults(csv_row)
    end

    def getSources(csv)
        sources = {}
        (1..8).each do |i|
            src = csv["source#{i}"].to_i
            count = csv["sourcecount#{i}"].to_i
            sources[src]=count if src>0 and count>0
        end
        return sources
    end

    def getResults(csv)
        res = {[@res_item1]=>@res_item1_count}
        (2..4).each do |i|
            src = csv["item#{i}"].to_i
            count = csv["item#{i}_count"].to_i
            res[src]=count if src>0 and count>0
        end
        return res
    end

    def Name(locales)
        name = locales[@id]

        if name.nil? then
            i_name = locales[@res_item1]
            if not i_name.nil? then
                name = locales["SYS_RECIPE_TITLE"]+i_name
            end
        end

        return name
    end

    def ExportDesc(data)
        data.push( "results")
    end

    def ExportData(data)
        data.push( FormatArray(@results.keys) )
    end
end

class Recipes < Table
    FILENAME = "recipeobject"

    CRAFTS={
        1=>"BLACKSMITH",
        2=>"CARPENTER",
        3=>"MAKEARMOR",
        4=>"TAILOR",
        5=>"COOK",
        6=>"ALCHEMY",
        7=>"LUMBERING",
        8=>"MINING",
        9=>"HERBLISM",
#~ "SYS_SKILLNAME_FISHING"="Fischerei"
#~ "SYS_SKILLNAME_PLANT"="Gärtnerei"
    }

    def initialize()
        super(RecipesEntry, FILENAME)
    end

    def self.CraftName(locales,id)
        raise "unknown craft: #{id}" if not CRAFTS.include? id
        return locales["SYS_SKILLNAME_"+CRAFTS[id]]
    end

    def ExportReverseIndex(filename)

        File.open(filename, 'wt') { |outf|
            outf.write( "-- RecipeEntry: item_id=recipe_id\n")

            outf.write("return {\n")
            sorted=db.sort {| a,b | a.res_item1<=>b.res_item1 }
            sorted.each { |data|
                next if not data.Export?
                next if data.res_item1==0
                outf.write( "  [%s]=%s,\n" % [data.res_item1, data.id])
                }
            outf.write("}\n")
        }
    end

end


