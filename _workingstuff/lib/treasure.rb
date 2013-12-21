require_relative 'table'

class TreasureEntry < TableEntry
    attr_reader :items

    def initialize(csv_row)
        super(csv_row)

        @items=[]
        item_count = csv_row['itemcount'].to_i
        for i in 1..item_count
            item = csv_row['treasureitem'+i.to_s].to_i
            chance = csv_row['treasurecount'+i.to_s].to_i / 1000
            count = csv_row['treasuredropcount'+i.to_s].to_i
            @items.push( { id: item, count: count, chance: chance } )
        end

        @type = csv_row['unk140'].to_i
    end

    def IsValid?
        return super()
    end

    def to_s(lang)
        res=""
        @items.sort { |a,b| b[:dropcount]<=>a[:dropcount] }
        .each { |i|
            l =""
            l = i[:count].to_s+"x "if i[:count]>1

            res += "%.0f%% %s%s (%i), " % [ i[:chance], l, lang[i[:id]], i[:id] ]
        }
        return res
    end

    def CollectItems(list=nil)
        list = {} if list.nil?

        @items.each { |i|
            list[ i[:id] ]=[] unless list.include? i[:id]
            list[ i[:id] ].push (i[:count])
        }
        return list
    end

    def ExportDesc(data)
    end

    def ExportData(data)
    end
end


class Treasure < Table
    FILENAME = "treasureobject"

    def initialize()
        super(TreasureEntry, FILENAME)
    end
end