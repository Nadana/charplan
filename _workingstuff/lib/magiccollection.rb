﻿class MagicCollectionEntry < TableEntry
    attr_accessor :magics
    attr_accessor :image_id
    attr_accessor :effecttype

    def initialize(csv_row)
        super(csv_row)
        @magics=[]
        for i in 1..12
            magic = csv_row['magicbaseid'+i.to_s].to_i
            @magics.push(magic) if magic>0
        end

        @effecttype = csv_row['effecttype'].to_i
        @image_id = csv_row['imageid'].to_i
    end

    def IsValid?
        #return false if @effecttype!=2  # passive spells only
        return (@magics.size!=0)
    end

    def ExportDesc(data)
        data.push( "effecttype")
        data.push( "image_id")
        data.push( "{magics}")
        data.push( "")
    end

    def ExportData(data)
        data.push(@effecttype)
        data.push(@image_id)
        data.push(FormatArray(@magics, true))
    end

end


class MagicCollection < Table
    FILENAME = "magiccollectobject"

    def initialize()
        super(MagicCollectionEntry, FILENAME)
    end

    def MarkSpellsUsed(spells)
        each { | data|
            undefined = []
            data.magics.each {|d|
                if spells.index.include?(d)
                    spells.Used(d)
                else
                    undefined.push(d)
                end
            }
            data.magics = data.magics-undefined
        }
    end
end