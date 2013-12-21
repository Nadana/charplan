class ItemsEntry < TableEntry

    attr_accessor :type
    attr_accessor :image_id
    attr_accessor :spell

    def initialize(csv_row)
        super(csv_row)
        @type = csv_row['itemtype'].to_i
        @spell = csv_row['incmagic_onuse'].to_i
        @image_id = csv_row['imageid'].to_i
    end

    def IsValid?
        return super()
    end

    def ExportDesc(data)
        data.push("magic")
    end

    def ExportData(data)
        data.push(@spell)
    end
end


class Items < Table
    FILENAME = "itemobject"

    def initialize()
        super(ItemsEntry, FILENAME)
    end

    def MarkSpellsUsed(spells)
        each { |data|
            if spells.db.include?(data.spell)
                spells.Used(data.spell)
            else
                data.NotUsed
            end
        }
    end

end